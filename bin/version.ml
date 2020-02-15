open Core

let common cli summary =
  Command.basic
    ~summary:summary
    Command.Let_syntax.(
      let%map_open
        _ = anon (maybe ("whatever" %: string))
      in
      fun () -> match cli with
        | "qshell" -> Lib.Qshell.version ()
        | "aws" -> Lib.Aws.version ()
        | _ -> print_endline "Must specify a cli name")

let qshell = common "qshell" "Run qshell --version"
let aws = common "aws" "Run aws --version"
