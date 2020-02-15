open Stdio

let version = fun () -> Run.run "qshell -v"

let buckets = fun () -> Run.run "qshell buckets"

let common_put mode = 
  fun bucket key local_file overwrite ->
  let cmd = String.concat " " ["qshell"; mode; bucket; key; local_file] in
  if overwrite then
    Run.run (cmd ^ " --overwrite")
  else
    Run.run cmd

let fput = common_put "fput"

let rput = common_put "rput"

let put ~bucket ~key ~file ~overwrite =
  let stats = Unix.stat file in
  let file_size =  ((float_of_int stats.st_size) /. 1024.0) in
  if file_size < 1024.0 *. 50.0 then
    (print_endline "Use fput for small file:";
     fput bucket key file overwrite)
  else
    (print_endline "Use rput for large file:";
     rput bucket key file overwrite)

let delete ~bucket ~key = Run.run ("qshell delete " ^ bucket ^ " " ^ key)

let cdn_refresh file = Run.run ("qshell cdnrefresh -i " ^ file)
 
