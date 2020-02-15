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

let process_upload bucket filename incl excl replace_first_path_to =
  match filename with
  | None ->
    print_endline
      "Must provide a filename or dirname to upload"
  | Some filename ->
    print_endline ("Bucket Name: " ^ bucket ^ "\n");
    print_endline "File or Dir will be uploaded:\n";
    print_endline (filename ^ "\n");
    Lib.Aws.cp  ~bucket ~key:(match replace_first_path_to with
        | None -> filename
        | Some path -> Lib.Dir.replace_file_first_path filename path
      ) ~file:filename ~incl:incl ~excl:excl

let upload =
  Command.basic
    ~summary:"Upload module of aws"
    Command.Let_syntax.(
      let%map_open
        bucket = flag "bucket" (required string)
          ~doc:"Specify a bucket name"
      and filename = anon (maybe ("filename" %: string))
      and incl = flag "include" (optional string)
          ~doc:"Include files"
      and excl = flag "exclude" (optional string)
          ~doc:"Exclude files"
      and replace_first_path_to = flag "replace-first-path-to" (optional string)
          ~doc:"Replace first path to"
      in
      fun () -> process_upload bucket filename incl excl replace_first_path_to)
