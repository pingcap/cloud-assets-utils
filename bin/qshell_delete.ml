open Core
open Stdio

let delete =
  Command.basic
    ~summary:"Delete module of qiniu"
    Command.Let_syntax.(
      let%map_open
        bucket = flag "bucket" (required string)
          ~doc:"Specify a bucket name"
      and filename = anon (maybe ("filename" %: string))
      in
      fun () -> match filename with
        | None -> print_endline "Must provide a filename to delete"
        | Some filename -> Lib.Qshell.delete ~bucket:bucket ~key:filename
    )
