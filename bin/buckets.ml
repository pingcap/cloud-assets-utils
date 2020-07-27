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

let common cli summary =
  Command.basic ~summary @@ Command.Param.return
  @@ fun () ->
  let open Lib in
  match cli with "qshell" -> Qshell.buckets () | "aws" -> Aws.buckets () | _ -> ()

let qshell = common "qshell" "Run qshell buckets"

let aws = common "aws" "Run aws s3 ls"
