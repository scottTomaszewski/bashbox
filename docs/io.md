## Index

* [bb.io.file_or_var](#bbiofileorvar)
* [bb.io.without_extensions](#bbiowithoutextensions)
* [bb.io.without_last_extension](#bbiowithoutlastextension)
* [bb.io.extensions](#bbioextensions)
* [bb.io.last_extension](#bbiolastextension)

### bb.io.file_or_var

If `filename_or_var` is a filepath and exists, runs `cat` on the file.  Otherwise, runs `echo` on `$filename_or_var`

For commands that only take a file, can be useful to do the following (where `INPUT` is either a filepath or string):
`command -f <(bb io.file_or_var "$INPUT")`

#### Arguments

* **$1** (string): `filename_or_var` A file path or content

#### Exit codes

* **0**: if successful
* **1**: if filename_or_var not provided

### bb.io.without_extensions

Removes all extensions from a file path.

#### Example

```bash
# prints `filename`
bb io.without_extensions "filename.tar.gz"
```

#### Arguments

* **$1** (string): `filename` A file name/path

#### Exit codes

* **0**: if successful
* **1**: if filename not provided

### bb.io.without_last_extension

Removes the last extensions from a file path

#### Example

```bash
# prints `filename.tar`
bb io.without_last_extension "filename.tar.gz"
```

#### Arguments

* **$1** (string): `filename` A file name/path

#### Exit codes

* **0**: if successful
* **1**: if filename not provided

### bb.io.extensions

Returns all extensions of a file path

#### Example

```bash
# prints `tar.gz`
bb io.extensions "filename.tar.gz"
```

#### Arguments

* **$1** (string): `filename` A file name/path

#### Exit codes

* **0**: if successful
* **1**: if filename not provided

### bb.io.last_extension

Returns last extension of a file path

#### Example

```bash
# prints `gz`
bb io.last_extension "filename.tar.gz"
```

#### Arguments

* **$1** (string): `filename` A file name/path

#### Exit codes

* **0**: if successful
* **1**: if filename not provided

