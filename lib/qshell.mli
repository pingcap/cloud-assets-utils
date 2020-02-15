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
