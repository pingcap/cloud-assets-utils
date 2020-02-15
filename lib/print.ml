open Stdio

type t = string

let rec print_string_list list =
  match list with
  | [] -> ()
  | hd :: tl -> (
      print_endline hd;
      print_string_list tl;
    )

let rec print_string2_list list =
  match list with
  | [] -> ()
  | hd :: tl -> (
      let (a, b) = hd in
      printf "%s %s\n" a b;
      print_string2_list tl;
    )
