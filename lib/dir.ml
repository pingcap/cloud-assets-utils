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

open Base
open Stdio

type t = string

type git_changed_file_with_status = {
  status: t;
  file: t;
}

let rec print_git_changed_files_list list =
  match list with
  | [] -> ()
  | hd :: tl -> (
      print_endline hd.file;
      print_git_changed_files_list tl;
    )

let dir_files dir =
  let rec loop result = function
    | f::fs when Caml.Sys.is_directory f ->
      Caml.Sys.readdir f
      |> Array.to_list
      |> List.map ~f:(Caml.Filename.concat f)
      |> List.append fs
      |> loop result
    | f::fs -> loop (f::result) fs
    | [] -> result
  in
  loop [] [dir]

let remove_file_first_path file =
  let last_path = file
                  |> String.split ~on:'/'
                  |> List.tl in
  match last_path with
  | None | Some([]) | Some([""]) -> ""
  | Some(last_path) -> String.concat ~sep:"/" last_path

let replace_file_first_path file new_first_path =
  new_first_path ^ "/" ^ (remove_file_first_path file)

let git_changed_files_from_HEAD dir =
  Run.exec ("git config core.quotePath false && git --no-pager show --pretty=\"\" --name-status " ^ dir)

let git_changed_files_from_HEAD_with_status dir =
  let re = Str.regexp "\\([A-Z0-9]+\\)\t\\(.+\\)" in
  let files = git_changed_files_from_HEAD dir in
  List.map
    ~f:(fun file ->
        let _ = Str.string_match re file 0 in
        let status = Str.matched_group 1 file in
        let file' = Str.matched_group 2 file in
        { status; file = file' }
      )
    files

let write_lines filename string_list = Out_channel.write_lines filename string_list
