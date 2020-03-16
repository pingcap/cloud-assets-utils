# cloud-assets-utils

Cloud assets utils by PingCAP FE.

## How to use

### Install qshell

<https://github.com/qiniu/qshell>

The version we used is:

> qshell version v2.4.1

#### Configure qshell

Type `qshell account`:

```sh
qshell account AccessKey SecretKey Name
```

Check qshell's configuration:

```sh
qshell account
qshell buckets # list all buckets
```

### Install awscli

```sh
pip install awscli
```

The version we used is:

> aws-cli/1.17.16 Python/3.7.6 Darwin/19.3.0 botocore/1.14.16

#### configure awscli

```sh
aws configure
```

Check awscli's configuration:

```sh
aws configure list
```

### Install cloud_assets_utils

#### Build from source

##### Install ocaml and opam

<http://ocaml.org/docs/install.html>

##### Install dependencies

```sh
opam install dune core

# For development (Optional)
opam install merlin ocp-indent utop
```
    
##### Build by dune

Into the repo, run:

```sh
dune build
```

The output file can be executed by:

```sh
./_build/default/bin/cloud_assets_utils.exe help
```

## Use it

Type `cloud_assets_utils help`:

```sh
Cloud assets utils by PingCAP FE.

  cloud_assets_utils.exe SUBCOMMAND

https://github.com/pingcap/cloud-assets-utils
version:0.2.1 (2020-02-15)

=== subcommands ===

  aws-buckets      Run aws buckets
  aws-delete       Delete module of aws
  aws-upload       Upload module of aws
  aws-version      Run aws --version
  qshell-buckets   Run qshell buckets
  qshell-delete    Delete module of qiniu
  qshell-upload    Upload module of qiniu
  qshell-version   Run qshell --version
  verify           Verify changed files
  verify-and-sync  Verify changed files and sync to oss
  version          print version information
  help             explain a given subcommand (perhaps recursively)
```

You can use the commands according to your needs.

For example, type `cloud_assets_utils qshell-upload -h`:

```sh
Upload module of qiniu

  cloud_assets_utils.exe qshell-upload [FILENAME]

=== flags ===

  -bucket Specify                   a bucket name
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
| verify-and-sync | `verify` and sync to oss (qiniu, aws)                   |

## Verify And Sync

This subcommand verify the last git commit files in a specific folder and sync the changes to oss.

Including add, modify and delete.

```sh
Verify changed files and sync to oss

  cloud_assets_utils.exe verify-and-sync [DIR]

=== flags ===

  [-aws Sync]                       files to aws
  [-aws-bucket Aws]                 bucket
  [-cdn-refresh Refresh]            cdn caches with
  [-qiniu Sync]                     files to qiniu
  [-qiniu-bucket Qiniu]             bucket
  [-replace-first-path-to Replace]  first path to
  [-help]                           print this help text and exit
                                    (alias: -?)
```

if you want to sync to aws, pass `-aws true -aws-bucket bucket` after `cloud_assets_utils verify-and-sync`.

Qiniu is the same.

The `-replace-first-path-to` replace the files' first path, for example:

`cloud_assets_utils verify-and-sync media -replace-first-path-to pingcap/test`

will replace `media/a.png` to `pingcap/test/a.png`.

## License

Under Apache-2.0.
