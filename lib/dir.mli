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

type t = string

type git_changed_file_with_status = {
  status: string;
  file: string;
}

val print_git_changed_files_list: git_changed_file_with_status list -> unit

(** [dir_files] returns the paths of all regular files that are contained in dir.

    Each file is a path starting with dir.
*)
val dir_files: t -> t list

val remove_file_first_path: t -> t

val replace_file_first_path: t -> t -> t

val git_changed_files_from_HEAD: t -> t list

val git_changed_files_from_HEAD_with_status:
  t -> git_changed_file_with_status list

val write_lines: t -> t list -> unit
