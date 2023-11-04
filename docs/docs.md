## Index

* [bb.docs.generate_for_bash](#bbdocsgenerateforbash)
* [_bb.docs.for_function](#bbdocsforfunction)

### bb.docs.generate_for_bash

---
Generates markdown documentation for bash scripts using shdoc

#### Arguments

* **$1** (string): `bash_dir` File path to a directory of bash scripts
* **$2** (string): `output_dir` File path to a directory to dump the markdown files

#### Exit codes

* **0**: if successful
* **1**: if args not provided or `shdoc` is not found

### _bb.docs.for_function

Prints out the docs of a function.

#### Example

```bash
_bb.docs.usage "${BASH_SOURCE[0]}" "${FUNCNAME[0]}"
```

