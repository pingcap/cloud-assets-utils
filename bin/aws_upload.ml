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

let process_upload bucket dryrun incl excl replace_first_path_to filename =
  let open Lib in
  print_endline ("Bucket Name: " ^ bucket);
  print_endline ("File or Dir will be uploaded: " ^ filename);
  Out_channel.newline stdout;
  Aws.cp ~bucket
    ~key:(match replace_first_path_to with None -> filename | Some path -> Dir.replace_file_first_path filename path)
    ~dryrun ~incl ~excl filename

let upload =
  Command.basic ~summary:"AWS CLI S3 Upload"
    Command.Let_syntax.(
      let%map_open bucket = flag "bucket" (required string) ~doc:"Specify the bucket name"
      and dryrun =
        flag "dryrun" (optional_with_default false bool)
          ~doc:
            "Displays the operations that would be performed using the specified command without actually running them"
      and incl =
        flag "include" (optional string)
          ~doc:"Don't exclude files or objects in the command that match the specified pattern"
      and excl =
        flag "exclude" (optional string)
          ~doc:"Exclude all files or objects from the command that matches the specified pattern"
      and replace_first_path_to = flag "replace-first-path-to" (optional string) ~doc:"Replace first path to"
      and filename = anon ("filename" %: string) in
      fun () -> process_upload bucket dryrun incl excl replace_first_path_to filename)
