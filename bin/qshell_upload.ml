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

let process_upload bucket filename overwrite replace_first_path_to =
  let open Lib in
  print_endline ("Bucket Name: " ^ bucket);
  print_endline ("Overwrite: " ^ string_of_bool overwrite);
  print_endline "Files will be uploaded:";
  Out_channel.newline stdout;
  let files = Dir.dir_files filename in
  match files with
  | [] -> print_endline "No files will be uploaded"
  | _ ->
      files |> Print.print_string_list;
      Out_channel.newline stdout;
      List.iter
        ~f:(fun file ->
          Qshell.put ~bucket
            ~key:(match replace_first_path_to with None -> file | Some path -> Dir.replace_file_first_path file path)
            ~file ~overwrite)
        files

let upload =
  Command.basic ~summary:"Qshell Upload"
    Command.Let_syntax.(
      let%map_open bucket = flag "bucket" (required string) ~doc:"Specify the bucket name"
      and overwrite = flag "overwrite" (optional_with_default false bool) ~doc:"Overwrite exist file or not"
      and replace_first_path_to = flag "replace-first-path-to" (optional string) ~doc:"Replace first path to"
      and filename = anon ("filename" %: string) in
      fun () -> process_upload bucket filename overwrite replace_first_path_to)
