open Core
open Stdio

let delete =
  Command.basic
    ~summary:"Delete module of aws"
    Command.Let_syntax.(
      let%map_open
        bucket = flag "bucket" (required string)
          ~doc:"Specify a bucket name"
      and filename = anon (maybe ("filename" %: string))
      and recursive = flag "recursive" (optional_with_default false bool)
          ~doc:"Delete recursively"
      and incl = flag "include" (optional string)
          ~doc:"Include files"
      and excl = flag "exclude" (optional string)
          ~doc:"Exclude files"
      in
      fun () -> match filename with
        | None -> print_endline "Must provide a filename to delete"
        | Some filename -> Lib.Aws.rm ~bucket:bucket ~key:filename ~recursive:recursive ~incl:incl ~excl:excl)
