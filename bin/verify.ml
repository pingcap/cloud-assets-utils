(* Copyright 2020 PingCAP, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License. *)

open Core
open Stdio

let changed_files =
  Command.basic ~summary:"Verify changed files from HEAD"
    Command.Let_syntax.(
      let%map_open dir = anon ("dir" %: string) in
      fun () ->
        let open Lib in
        Print.print_string_list (Dir.git_changed_files_from_HEAD dir))

let process_changed_files_and_sync ~qiniu ~qiniu_bucket ~aws ~aws_bucket ~replace_first_path_to ~cdn_refresh dir =
  match dir with
  | "." -> print_endline "Can't specify the whole dir"
  | _ ->
      let open Lib in
      let replace_first_path_to = match replace_first_path_to with None -> "" | Some path -> path
      and files = Dir.git_changed_files_from_HEAD_with_status dir in
      let replace_or_not file =
        if equal_string replace_first_path_to "" then Dir.remove_file_first_path file
        else Dir.replace_file_first_path file replace_first_path_to
      in
      let added_files = List.filter ~f:(fun file -> String.compare file.status "A" = 0) files in
      let modified_files = List.filter ~f:(fun file -> String.compare file.status "M" = 0) files in
      let deleted_files = List.filter ~f:(fun file -> String.compare file.status "D" = 0) files in
      let renamed_files = List.filter ~f:(fun file -> String.compare file.status "R" = 0) files in

      print_endline "Files will be sync:";
      Out_channel.newline stdout;

      print_endline "Added:";
      Out_channel.newline stdout;
      Dir.print_git_changed_files_list added_files;
      Out_channel.newline stdout;

      print_endline "Modified:";
      Out_channel.newline stdout;
      Dir.print_git_changed_files_list modified_files;
      Out_channel.newline stdout;

      print_endline "Deleted:";
      Out_channel.newline stdout;
      Dir.print_git_changed_files_list deleted_files;
      Out_channel.newline stdout;

      print_endline "Renamed:";
      Out_channel.newline stdout;
      Dir.print_git_changed_files_list renamed_files;
      Out_channel.newline stdout;

      if qiniu then (
        match qiniu_bucket with
        | None -> print_endline "Must provide the qiniu bucket"
        | Some qiniu_bucket ->
            print_endline "Sync files to qiniu:";

            (* Added *)
            List.iter
              ~f:(fun f -> Qshell.put ~bucket:qiniu_bucket ~key:(replace_or_not f.file) ~file:f.file ~overwrite:true)
              added_files;

            (* Modified *)
            List.iter
              ~f:(fun f -> Qshell.put ~bucket:qiniu_bucket ~key:(replace_or_not f.file) ~file:f.file ~overwrite:true)
              modified_files;
            ( match cdn_refresh with
            | None -> ()
            | Some cdn_refresh ->
                let need_refreshed_files = List.map ~f:(fun f -> cdn_refresh ^ replace_or_not f.file) modified_files in
                let filename = "need_refreshed_files" in
                Dir.write_lines filename need_refreshed_files;
                Qshell.cdn_refresh filename );

            (* Deleted *)
            List.iter ~f:(fun f -> Qshell.delete ~bucket:qiniu_bucket ~key:(replace_or_not f.file)) deleted_files;

            (* Renamed *)
            List.iter
              ~f:(fun f ->
                let files_array = String.split ~on:'\t' f.file |> Array.of_list in
                Qshell.delete ~bucket:qiniu_bucket ~key:(replace_or_not files_array.(0));
                Qshell.put ~bucket:qiniu_bucket
                  ~key:(replace_or_not files_array.(1))
                  ~file:files_array.(1) ~overwrite:true)
              renamed_files )
      else print_endline "Not sync to qiniu";

      if aws then (
        match aws_bucket with
        | None -> print_endline "Must provide the aws bucket"
        | Some aws_bucket ->
            print_endline "Sync files to aws:";

            (* Added *)
            List.iter
              ~f:(fun f -> Aws.cp ~bucket:aws_bucket ~key:(replace_or_not f.file) ~incl:None ~excl:None f.file)
              added_files;

            (* Modified *)
            List.iter
              ~f:(fun f -> Aws.cp ~bucket:aws_bucket ~key:(replace_or_not f.file) ~incl:None ~excl:None f.file)
              modified_files;

            (* Deleted *)
            List.iter
              ~f:(fun f -> Aws.rm ~bucket:aws_bucket ~recursive:false ~incl:None ~excl:None (replace_or_not f.file))
              deleted_files;

            (* Renamed *)
            List.iter
              ~f:(fun f ->
                let files_array = String.split ~on:'\t' f.file |> Array.of_list in
                Aws.rm ~bucket:aws_bucket ~recursive:false ~incl:None ~excl:None (replace_or_not files_array.(0));
                Aws.cp ~bucket:aws_bucket ~key:(replace_or_not files_array.(1)) ~incl:None ~excl:None files_array.(1))
              renamed_files )
      else print_endline "Not sync to aws"

let changed_files_and_sync =
  Command.basic ~summary:"Verify changed files from HEAD and sync to oss"
    Command.Let_syntax.(
      let%map_open qiniu = flag "qiniu" (optional_with_default false bool) ~doc:"Sync files to qiniu"
      and aws = flag "aws" (optional_with_default false bool) ~doc:"Sync files to aws"
      and qiniu_bucket = flag "qiniu-bucket" (optional string) ~doc:"Specify the qiniu bucket"
      and aws_bucket = flag "aws-bucket" (optional string) ~doc:"Specify the aws bucket"
      and replace_first_path_to = flag "replace-first-path-to" (optional string) ~doc:"Replace first path to"
      and cdn_refresh = flag "cdn-refresh" (optional string) ~doc:"Refresh cdn caches with"
      and dir = anon ("dir" %: string) in
      fun () ->
        process_changed_files_and_sync ~qiniu ~qiniu_bucket ~aws ~aws_bucket ~replace_first_path_to ~cdn_refresh dir)
