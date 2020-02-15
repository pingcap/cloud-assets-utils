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

(** Print qshell version *)
val version: unit -> unit

(** Get all buckets of the qiniu account *)
val buckets: unit -> unit

val common_put: string -> string -> string -> string -> bool -> unit

val fput: string -> string -> string -> bool -> unit

val rput: string -> string -> string -> bool -> unit

val put:
  bucket:string -> key:string -> file:string -> overwrite:bool -> unit

val delete: bucket:string -> key:string -> unit

val cdn_refresh: string -> unit
