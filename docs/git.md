## Index

* [bb.git.get_ref](#bbgitgetref)
* [bb.git.last_tag](#bbgitlasttag)
* [bb.git.remote.expand_sha](#bbgitremoteexpandsha)

### bb.git.get_ref

---
Prints the best ref possible for the current HEAD: Git tag if available, or the branch name if available, or the SHA.

Source: https://stackoverflow.com/a/55276236

#### Example

```bash
# prints `main`, the current branch
bb git.get_ref
```

#### Exit codes

* **0**: if successful

### bb.git.last_tag

---
Prints the most recently created tag according to the git history

#### Example

```bash
# prints `v1.0.0`
bb git.last_tag
```

#### Exit codes

* **0**: if successful

### bb.git.remote.expand_sha

---
Expands a git short sha into its full form.

If the `repo_url` doesnt match the current directory, this function will attempt to expand the SHA remotely which may
require a full git clone which can be slow on large repos.  If you already have the repo cloned, using
`git rev-parse <short-sha>` directly is faster.

#### Example

```bash
# prints `25291a8fe1aa01cf105be0b9516b3de2a7ebe118`
bb git.remote.expand_sha 25291a8fe https://github.com/scottTomaszewski/bashbox/
```

#### Exit codes

* **0**: if successful

