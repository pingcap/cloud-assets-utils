# cloud-assets-utils

Cloud assets utils by PingCAP FE.

Its main purpose is to unify the operation of Qiniu and AWS S3.

![OCaml Version](https://img.shields.io/badge/OCaml-4.10.0-000?logo=ocaml)
![Upload changed files to Qiniu and AWS S3](https://github.com/pingcap/cloud-assets-utils/workflows/Upload%20changed%20files%20to%20Qiniu%20and%20AWS%20S3/badge.svg)
[![CircleCI](https://circleci.com/gh/pingcap/cloud-assets-utils.svg?style=svg)](https://circleci.com/gh/pingcap/cloud-assets-utils)

- [How to use](#how-to-use)
  - [Use in CI](#use-in-ci)
  - [Install and configure qshell](#install-and-configure-qshell)
  - [Install and configure awscli](#install-and-configure-awscli)
  - [Install cloud_assets_utils](#install-cloud_assets_utils)
- [Use it](#use-it)
- [All subcommands](#all-subcommands)
- [Verify And Sync](#verify-and-sync)
  - [Replace first path to](#replace-first-path-to)
  - [CDN refresh](#cdn-refresh)
- [License](#license)

## How to use

### Use in CI

This tool is usually used in CI. You can find binaries in [Release](https://github.com/pingcap/cloud-assets-utils/releases). Download and use it.

Also, we test it in circleci and GitHub actions. View these files for more details:

- [.circleci/config.yml](https://github.com/pingcap/cloud-assets-utils/blob/master/.circleci/config.yml)
- [.github/workflows/test.yml](https://github.com/pingcap/cloud-assets-utils/blob/master/.github/workflows/test.yml)
- [use-in-github-actions-template.yml](https://github.com/pingcap/cloud-assets-utils/blob/master/use-in-github-actions-template.yml)

If you want to use it in a local machine. Please read below carefully.

### Install and configure qshell

The [qshell](https://github.com/qiniu/qshell) we used is `v2.4.2`:

```sh
qshell account AccessKey SecretKey Name
```

Check qshell's configuration:

```sh
qshell account
qshell buckets # list all buckets
```

### Install and configure awscli

```sh
pip install awscli
```

The version we used is `aws-cli/1.18.105 Python/3.7.6 Darwin/19.6.0 botocore/1.17.28`:

```sh
aws configure
```

Check awscli's configuration:

```sh
aws configure list
```

### Install cloud_assets_utils

Install OCaml and Opam:

<http://ocaml.org/docs/install.html>

Install dependencies:

```sh
opam install dune core

# For development (Optional)
opam install merlin ocp-indent utop ocamlformat
```

Build by dune:

```sh
dune build
```

The output file can be executed by:

```sh
./_build/default/bin/cloud_assets_utils.exe help
```

Or merge two commands to one:

```sh
dune exec -- bin/cloud_assets_utils.exe help
```

## Use it

Type `cloud_assets_utils help`:

```sh
Cloud assets utils by PingCAP FE.

  cloud_assets_utils.exe SUBCOMMAND

https://github.com/pingcap/cloud-assets-utils
version:0.2.2 (2020-07-27)

=== subcommands ===

  aws-buckets      Run `aws s3 ls`
  aws-delete       AWS CLI S3 Delete
  aws-upload       AWS CLI S3 Upload
  aws-version      Run `aws --version`
  qshell-buckets   Run `qshell buckets`
  qshell-delete    Qshell Delete
  qshell-upload    Qshell Upload
  qshell-version   Run `qshell --version`
  verify           Verify changed files from HEAD
  verify-and-sync  Verify changed files from HEAD and sync to oss
  version          print version information
  help             explain a given subcommand (perhaps recursively)
```

You can use the commands according to your needs.

For example, type `cloud_assets_utils qshell-upload -h`:

```sh
Qshell Upload

  cloud_assets_utils.exe qshell-upload FILENAME

=== flags ===

  -bucket Specify                   the bucket name
  [-overwrite Overwrite]            exist file or not
  [-replace-first-path-to Replace]  first path to
  [-help]                           print this help text and exit
                                    (alias: -?)
```

## All subcommands

| Command         | Action                                                  |
| --------------- | ------------------------------------------------------- |
| aws-buckets     | Same as `aws s3 ls`                                     |
| aws-delete      | Delete a file or a folder                               |
| aws-upload      | Upload a file or a folder                               |
| aws-version     | Same as `aws --version`                                 |
| qshell-buckets  | Same as `qshell buckets`                                |
| qshell-delete   | Delete a file                                           |
| qshell-upload   | Upload a file or all files in a folder                  |
| qshell-version  | Same as `qshell -v`                                     |
| verify          | Same as `git --no-pager show --pretty="" --name-status` |
| verify-and-sync | `verify` and sync to oss (qiniu, aws s3)                |

## Verify and Sync

This subcommand verify the last git commit files in a specific folder and sync the changes to oss.

Supported changes: **Added**, **Modified** and **Deleted**.

```sh
Verify changed files from HEAD and sync to oss

  cloud_assets_utils.exe verify-and-sync DIR

=== flags ===

  [-aws Sync]                       files to aws
  [-aws-bucket Specify]             the aws bucket
  [-cdn-refresh Refresh]            cdn caches with
  [-qiniu Sync]                     files to qiniu
  [-qiniu-bucket Specify]           the qiniu bucket
  [-replace-first-path-to Replace]  first path to
  [-help]                           print this help text and exit
                                    (alias: -?)
```

if you want to sync to aws, pass `-aws true -aws-bucket bucket` after `cloud_assets_utils verify-and-sync`.

Qiniu is the same.

### Replace first path to

The `-replace-first-path-to` replace the files' first path, for example:

`cloud_assets_utils verify-and-sync media -replace-first-path-to pingcap/test`

will replace `media/a.png` to `pingcap/test/a.png`.

### CDN refresh

> Note: only for Qiniu

Qiniu will cache the most recent upload files so maybe you need to refresh it to make it at the latest.

Pass `-cdn-refresh URL_PRIFIX` to take its effect on the modified files.

## License

Under Apache 2.0 license.
