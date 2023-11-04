## Index

* [bb.git.notes.fetch](#bbgitnotesfetch)
* [bb.git.notes.log](#bbgitnoteslog)
* [bb.git.notes.kv.get](#bbgitnoteskvget)
* [bb.git.notes.kv.remote.get](#bbgitnoteskvremoteget)
* [bb.git.notes.kv.set](#bbgitnoteskvset)

### bb.git.notes.fetch

---
Fetches git notes from remote

#### Example

```bash
bb git.notes.fetch
```

#### Exit codes

* **0**: if successful

### bb.git.notes.log

---
Fetches git notes from remote, then runs git log

#### Example

```bash
bb git.notes.log
```

#### Exit codes

* **0**: if successful

### bb.git.notes.kv.get

---
Retrieves the value for a specified `key` in the git notes of the specified `ref`.

If there are multiple lines in the git notes with the same key, the value of the last one will be returned.  If the
git repo is a shallow clone, this function will `fetch --unshallow` to attempt to find the `ref`.

#### Example

```bash
# this will get the value of key `metadata` in the git notes of commit ec95e1f0d6e06ba7e51e8c5573b14394c8a1fb55
bb git.notes.kv.get metadata ec95e1f0d6e06ba7e51e8c5573b14394c8a1fb55
#
# this will get the value of key `metadata` in the git notes of HEAD and defaults to `{"foo":"bar"}` if not found
bb git.notes.kv.get metadata ec95e1f0d6e06ba7e51e8c5573b14394c8a1fb55 "{\"foo\":\"bar\"}"
```

#### Arguments

* **$1** (string): `key` Key portion of a key-value pair in git-notes entry
* **$2** (string): `ref` (Optional) Git object ref commit hash, tag, etc. Defaults to HEAD
* **$3** (string): `default_value` (Optional) Value to print if `key` is not found in git notes. Defaults to empty string
* **$4** (string): `default_message` (Optional) Message to print to stderr if default_value is used. Doesnt print if not provided.

#### Exit codes

* **0**: if successful

### bb.git.notes.kv.remote.get

---
Retrieves the value for a specified `key` in the git notes of the specified `ref` for the repo at `repo_url`

If there are multiple lines in the git notes with the same key, the value of the last one will be returned.

#### Example

```bash
# Gets the value of key `metadata` in the git notes of commit `ec95e1f0d6e06ba7e51e8c5573b14394c8a1fb55` for repo `https://github.com/scottTomaszewski/bashbox/`
bb git.notes.kv.remote.get metadata ec95e1f0d6e06ba7e51e8c5573b14394c8a1fb55 https://github.com/scottTomaszewski/bashbox/
```

#### Arguments

* **$1** (string): `key` Key portion of a key-value pair in git-notes entry
* **$2** (string): `ref` (Optional) Git object ref commit hash, tag, etc. Defaults to HEAD

#### Exit codes

* **0**: if successful

### bb.git.notes.kv.set

---
Sets the value for a specified `key` in the git notes on `HEAD` ref and pushes the change.

There is currently no guarantee of the order of keys and ordering cannot be relied on.

If there are push rules for the git commit message on the repo, you will need to update the
regex to allow for commit messages that start with `Notes \w+ by` or equivalent.

#### Example

```bash
# this will set the value of key `metadata` to `{"foo": "bar"}` in the git notes of `HEAD`
bb git.notes.kv.set metadata '{"foo": "bar"}'
#
```

#### Arguments

* **$1** (string): `key` Key portion of a key-value pair in git-notes entry
* **$2** (string): `value` Value to assign to `key`
* **$3** (string): `branch` (Optional) Branch to push to in case of detached HEAD.

#### Exit codes

* **0**: if successful

