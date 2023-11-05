## Index

* [bb.preconditions.not_null](#bbpreconditionsnotnull)
* [bb.preconditions.has_command](#bbpreconditionshascommand)
* [bb.preconditions.require_command](#bbpreconditionsrequirecommand)
* [bb.preconditions.require_file](#bbpreconditionsrequirefile)

### bb.preconditions.not_null

---
Returns a non-zero exit code and prints error if `var_name` does not resolve to a non-empty value.

IMPORTANT: The `var_name` arg is just the *name* not the expanded variable.  This allows for a more useful
error message

#### Example

```bash
# Returns exit code 127 and prints "[ERROR] Expected [fake_var] to have value, but was empty." to stderr
bb preconditions.not_null "fake_var"
#
# Returns exit code 127 and prints "[ERROR] Missing var!" to stderr
bb preconditions.not_null "fake_var" "Missing var!"
#
# Common pattern to print error and exit function
bb preconditions.not_null "fake_var" || return $?
```

#### Arguments

* **$1** (string): `var_name` Variable name to check
* **$2** (string): `error_message` (Optional) Error message to print if `var_name` value is empty. Defaults to

#### Exit codes

* **0**: if successful
* **1**: if `var_name` arg not provided
* **127**: if `var_name` value is empty

### bb.preconditions.has_command

---
Returns a non-zero exit code if `command` is not available.

#### Example

```bash
# Returns exit code 127
bb preconditions.require_command fake_command
```

#### Arguments

* **$1** (string): `command` Command to check availability of

#### Exit codes

* **0**: if successful
* **1**: if `command` arg not provided
* **127**: if command not found

### bb.preconditions.require_command

---
Returns a non-zero exit code and prints error if `command` is not available.

#### Example

```bash
# Returns exit code 127 and prints "[ERROR] Command not found: fake_command" to stderr
bb preconditions.require_command fake_command
#
# Common pattern to print error and exit function
bb preconditions.require_command fake_command || return $?
```

#### Arguments

* **$1** (string): `command` Command to check availability of

#### Exit codes

* **0**: if successful
* **1**: if `command` arg not provided
* **127**: if command not found

### bb.preconditions.require_file

---
Returns a non-zero exit code and prints error if `filepath` is not found.

#### Example

```bash
# Returns exit code 127 and prints "[ERROR] Precondition failed: Expected file at fake_file but is missing." to stderr
bb preconditions.require_file fake_file
#
# Common pattern to print error and exit function
bb preconditions.require_file fake_file || return $?
```

#### Arguments

* **$1** (string): `filepath` File path to check availability of

#### Exit codes

* **0**: if successful
* **1**: if `filepath` arg not provided
* **127**: if filepath not found

