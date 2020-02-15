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

let delete =
  Command.basic
    ~summary:"Delete module of aws"
    Command.Let_syntax.(
      let%map_open
        bucket = flag "bucket" (required string)
          ~doc:"Specify a bucket name"
      and filename = anon (maybe ("filename" %: string))
      and recursive = flag "recursive" (optional_with_default false bool)
          ~doc:"Delete recursively"
      and incl = flag "include" (optional string)
          ~doc:"Include files"
      and excl = flag "exclude" (optional string)
          ~doc:"Exclude files"
      in
      fun () -> match filename with
        | None -> print_endline "Must provide a filename to delete"
        | Some filename -> Lib.Aws.rm ~bucket:bucket ~key:filename ~recursive:recursive ~incl:incl ~excl:excl)
