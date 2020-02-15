(** Print awscli version *)
val version: unit -> unit

(** Get all buckets of the aws account *)
val buckets: unit -> unit

val cp: 
  bucket:string -> ?key:string -> file:string -> incl:string option -> excl:string option -> unit

val rm:
  bucket:string -> key:string -> recursive:bool -> incl:string option -> excl:string option -> unit
