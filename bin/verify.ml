open Core
open Stdio

let changed_files =
  Command.basic
    ~summary:"Verify changed files"
    Command.Let_syntax.(
      let%map_open
        dir = anon (maybe ("dir" %: string))
      in
      fun () -> match dir with
        | None -> print_endline "Must specify a dir to verify"
        | Some dir ->
          let open Lib in
          Print.print_string_list (Dir.git_changed_files_from_HEAD dir))

let process_changed_files_and_sync dir ~qiniu ~aws ~qiniu_bucket ~aws_bucket ~replace_first_path_to ~cdn_refresh =
  match dir with
  | None -> print_endline "Must specify a dir to verify"
  | Some "." -> print_endline "Can't specify the whole dir"
  | Some dir ->
    let open Lib in
    let replace_first_path_to = match replace_first_path_to with
      | None -> ""
      | Some path -> path
    and files = Dir.git_changed_files_from_HEAD_with_status dir in
    let replace_or_not = fun file ->
      if equal_string replace_first_path_to "" then
        Dir.remove_file_first_path file
      else
        Dir.replace_file_first_path file replace_first_path_to in
    let added_files = List.filter ~f:(fun file -> file.status.[0] = 'A') files in
    let modified_files = List.filter ~f:(fun file -> file.status.[0] = 'M') files in
    let deleted_files = List.filter ~f:(fun file -> file.status.[0] = 'D') files in
    let renamed_files = List.filter ~f:(fun file -> file.status.[0] = 'R') files in
    print_endline "Files will be synced:\n";
    print_endline "Added:\n";
    Dir.print_git_changed_files_list added_files;
    print_endline "\nModified:\n";
    Dir.print_git_changed_files_list modified_files;
    print_endline "\nDeleted:\n";
    Dir.print_git_changed_files_list deleted_files;
    print_endline "\nRenamed:\n";
    Dir.print_git_changed_files_list renamed_files;
    if qiniu then
      match qiniu_bucket with
      | None -> print_endline "\nMust provide qiniu bucket\n"
      | Some qiniu_bucket ->
        print_endline "\nSync files to qiniu:\n";

        (* Added *)
        List.iter ~f:(fun f -> Qshell.put ~bucket:qiniu_bucket ~key:(replace_or_not f.file) ~file:f.file ~overwrite:true) added_files;

        (* Modified *)
        List.iter ~f:(fun f -> Qshell.put ~bucket:qiniu_bucket ~key:(replace_or_not f.file) ~file:f.file ~overwrite:true) modified_files;
        (match cdn_refresh with
         | None -> ()
         | Some cdn_refresh ->
           let need_refreshed_files = List.map ~f:(fun f -> cdn_refresh ^ (replace_or_not f.file)) modified_files in
           let filename = "need_refreshed_files" in (
             Dir.write_lines filename need_refreshed_files;
             Qshell.cdn_refresh filename
           ));

        (* Deleted *)
        List.iter ~f:(fun f -> Qshell.delete ~bucket:qiniu_bucket ~key:(replace_or_not f.file)) deleted_files;

        (* Renamed *)
        List.iter ~f:(fun f ->
            let files_array = String.split ~on:'\t' f.file |> Array.of_list in
            Qshell.delete ~bucket:qiniu_bucket ~key:(replace_or_not files_array.(0));
            Qshell.put ~bucket:qiniu_bucket ~key:(replace_or_not files_array.(1)) ~file:files_array.(1) ~overwrite:true
          ) renamed_files;
    else print_endline "\nNot sync to qiniu\n";
    if aws then
      match aws_bucket with
      | None -> print_endline "\nMust provide aws bucket\n"
      | Some aws_bucket ->
        print_endline "\nSync files to aws:\n";

        (* Added *)
        List.iter ~f:(fun f -> Aws.cp ~bucket:aws_bucket ~key:(replace_or_not f.file) ~file:f.file ~incl:None ~excl:None) added_files;

        (* Modified *)
        List.iter ~f:(fun f -> Aws.cp ~bucket:aws_bucket ~key:(replace_or_not f.file) ~file:f.file ~incl:None ~excl:None) modified_files;

        (* Deleted *)
        List.iter ~f:(fun f -> Aws.rm ~bucket:aws_bucket ~key:(replace_or_not f.file) ~recursive:false ~incl:None ~excl:None) deleted_files;

        (* Renamed *)
        List.iter ~f:(fun f ->
            let files_array = String.split ~on:'\t' f.file |> Array.of_list in
            Aws.rm ~bucket:aws_bucket ~key:(replace_or_not files_array.(0)) ~recursive:false ~incl:None ~excl:None;
            Aws.cp ~bucket:aws_bucket ~key:(replace_or_not files_array.(1)) ~file:files_array.(1) ~incl:None ~excl:None
          ) renamed_files;
    else print_endline "\nNot sync to aws\n"

let changed_files_and_sync =
  Command.basic
    ~summary:"Verify changed files and sync to oss"
    Command.Let_syntax.(
      let%map_open
        dir = anon (maybe ("dir" %: string))
      and qiniu = flag "qiniu" (optional_with_default false bool)
          ~doc:"Sync files to qiniu"
      and aws = flag "aws" (optional_with_default false bool)
          ~doc:"Sync files to aws"
      and qiniu_bucket = flag "qiniu-bucket" (optional string)
          ~doc:"Qiniu bucket"
      and aws_bucket = flag "aws-bucket" (optional string)
          ~doc:"Aws bucket"
      and replace_first_path_to = flag "replace-first-path-to" (optional string)
          ~doc:"Replace first path to"
      and cdn_refresh = flag "cdn-refresh" (optional string)
          ~doc:"Refresh cdn caches with"
      in
      fun () -> process_changed_files_and_sync dir
          ~qiniu:qiniu
          ~aws:aws
          ~qiniu_bucket:qiniu_bucket
          ~aws_bucket:aws_bucket
          ~replace_first_path_to:replace_first_path_to
          ~cdn_refresh:cdn_refresh
    )
