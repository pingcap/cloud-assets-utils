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

let version () = Run.run "aws --version"

let buckets () = Run.run "aws s3 ls"

let cp ~bucket ?key ?(dryrun = false) ~incl ~excl file =
  let dryrun = if dryrun then "--dryrun" else "" in
  let recursive = if Sys.is_directory file then "--recursive" else "" in
  let incl = match incl with None -> "" | Some incl -> "--include " ^ incl in
  let excl = match excl with None -> "" | Some excl -> "--exclude " ^ excl in
  let cmd =
    String.concat " "
      [
        "aws s3 cp";
        file;
        ("s3://" ^ bucket ^ "/" ^ match key with None -> file | Some key -> key);
        dryrun;
        recursive;
        incl;
        excl;
      ]
  in
  Run.run cmd

let rm ~bucket ?(dryrun = false) ~recursive ~incl ~excl key =
  let dryrun = if dryrun then "--dryrun" else "" in
  let recursive = if recursive then "--recursive" else "" in
  let incl = match incl with None -> "" | Some incl -> "--include " ^ incl in
  let excl = match excl with None -> "" | Some excl -> "--exclude " ^ excl in
  let cmd = String.concat " " [ "aws s3 rm"; "s3://" ^ bucket ^ "/" ^ key; dryrun; recursive; incl; excl ] in
  Run.run cmd
