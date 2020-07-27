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

let version () = Run.run "qshell -v"

let buckets () = Run.run "qshell buckets"

let common_put mode bucket key local_file overwrite =
  let cmd = String.concat " " [ "qshell"; mode; bucket; key; local_file ] in
  if overwrite then Run.run (cmd ^ " --overwrite") else Run.run cmd

let fput = common_put "fput"

let rput = common_put "rput"

let put ~bucket ~key ~file ~overwrite =
  let stats = Unix.stat file in
  let file_size = float_of_int stats.st_size /. 1024.0 in
  (* if file_size > 50MB, use rput *)
  if file_size < 1024.0 *. 50.0 then (
    print_endline "Use fput for small file:";
    fput bucket key file overwrite )
  else (
    print_endline "Use rput for large file:";
    rput bucket key file overwrite )

let delete ~bucket ~key = Run.run ("qshell delete " ^ bucket ^ " " ^ key)

let cdn_refresh file = Run.run ("qshell cdnrefresh -i " ^ file)
