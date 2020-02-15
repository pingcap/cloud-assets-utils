open Core
open Stdio

let common cli summary =
  Command.basic
    ~summary:summary
    Command.Let_syntax.(
      let%map_open
        _ = anon (maybe ("whatever" %: string))
      in
      fun () -> match cli with
        | "qshell" -> Lib.Qshell.buckets ()
        | "aws" -> Lib.Aws.buckets ()
        | _ -> print_endline "Must specify a cli name")

let qshell = common "qshell" "Run qshell buckets"
let aws = common "aws" "Run aws buckets"
