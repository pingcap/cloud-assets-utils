open Stdio

type t = string

let exec cmd = 
  let in_channel = Unix.open_process_in cmd in
  let output = In_channel.input_lines in_channel in
  In_channel.close in_channel;
  output

let run cmd = Print.print_string_list (exec cmd)
