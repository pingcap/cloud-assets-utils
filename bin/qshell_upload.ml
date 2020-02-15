open Core
open Stdio

let process_upload bucket filename overwrite replace_first_path_to =
  match filename with
  | None -> print_endline "Must provide a filename or dirname to upload"
  | Some filename ->
    let open Lib in
    print_endline ("Bucket Name: " ^ bucket);
    print_endline ("Overwrite: " ^ string_of_bool overwrite ^ "\n");
    print_endline "Files will be uploaded:\n";
    let files = Dir.dir_files filename in
    match files with
    | [] ->
      print_endline "No files will be uploaded"
    | _ ->
      files
      |> Print.print_string_list;
      print_endline "";
      List.iter
        ~f:(fun file ->
            Qshell.put
              ~bucket
              ~key:(match replace_first_path_to with
                  | None -> file
                  | Some path -> Lib.Dir.replace_file_first_path file path)
              ~file:file ~overwrite:overwrite)
        files

let upload =
  Command.basic
    ~summary:"Upload module of qiniu"
    Command.Let_syntax.(
      let%map_open
        bucket = flag "bucket" (required string)
          ~doc:"Specify a bucket name"
      and
        overwrite = flag "overwrite" (optional_with_default false bool)
          ~doc:"Overwrite exist file or not"
      and filename = anon (maybe ("filename" %: string))
      and replace_first_path_to = flag "replace-first-path-to" (optional string)
          ~doc:"Replace first path to"
      in
      fun () -> process_upload bucket filename overwrite replace_first_path_to)
