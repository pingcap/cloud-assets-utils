let version = fun () -> Run.run "aws --version"

let buckets = fun () -> Run.run "aws s3 ls"

let cp ~bucket ?key ~file ~incl ~excl = 
  let recursive = if Sys.is_directory file then "--recursive" else "" in
  let incl = match incl with
    | None -> ""
    | Some incl -> "--include " ^ incl in
  let excl = match excl with
    | None -> ""
    | Some excl -> "--exclude " ^ excl in
  let cmd = String.concat " " ["aws s3 cp"; 
                               file; 
                               "s3://" ^ bucket ^ "/" ^ (match key with
                                   | None -> file
                                   | Some key -> key); 
                               recursive;
                               incl;
                               excl] in
  Run.run cmd

let rm ~bucket ~key ~recursive ~incl ~excl =
  let recursive = if recursive then "--recursive" else "" in
  let incl = match incl with
    | None -> ""
    | Some incl -> "--include " ^ incl in
  let excl = match excl with
    | None -> ""
    | Some excl -> "--exclude " ^ excl in
  let cmd = String.concat " " ["aws s3 rm"; 
                               "s3://" ^ bucket ^ "/" ^ key;
                               recursive;
                               incl;
                               excl] in
  Run.run cmd
