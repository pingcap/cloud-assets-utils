type t = string

(** Exec command and collect its output, return a string list *)
val exec: t -> t list

(** [exec] and print *)
val run: t -> unit
