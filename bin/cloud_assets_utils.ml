open Core

let version = "version:0.2.0 (2020-02-15)"
let build_info = "Cloud assets utils by PingCAP FE."
let repo_url = "https://github.com/pingcap/cloud-assets-utils"

let command =
  Command.group
    ~summary:build_info
    ~readme:(fun () -> repo_url ^ "\n" ^ version)
    [
      (* qshell *)
      "qshell-upload", Qshell_upload.upload;
      "qshell-delete", Qshell_delete.delete;
      "qshell-version", Version.qshell;
      "qshell-buckets", Buckets.qshell;
      (* aws *)
      "aws-upload", Aws_upload.upload;
      "aws-delete", Aws_delete.delete;
      "aws-version", Version.aws;
      "aws-buckets", Buckets.aws;
      (* common *)
      "verify", Verify.changed_files;
      "verify-and-sync", Verify.changed_files_and_sync]

let () =
  Command.run
    ~version:version
    ~build_info:build_info
    command
