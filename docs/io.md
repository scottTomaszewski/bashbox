## Index

* [bb.io.file_or_var](#bbiofileorvar)

### bb.io.file_or_var

If `filename_or_var` is a filepath and exists, runs `cat` on the file.  Otherwise, runs `echo` on `$filename_or_var`

For commands that only take a file, can be useful to do the following (where `INPUT` is either a filepath or string):
`command -f <(bb io.file_or_var "$INPUT")`

#### Arguments

* **$1** (string): `filename_or_var` A file path or content

#### Exit codes

* **0**: if successful
* **1**: if filename_or_var not provided

