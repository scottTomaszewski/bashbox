## Index

* [bb.log.info](#bbloginfo)
* [bb.log.warn](#bblogwarn)
* [bb.log.warning](#bblogwarning)
* [bb.log.error](#bblogerror)
* [bb.log.title](#bblogtitle)
* [bb.log.header](#bblogheader)
* [bb.log.mocking](#bblogmocking)
* [bb.log.color](#bblogcolor)
* [bb.log.color.code](#bblogcolorcode)
* [bb.log.color.options](#bblogcoloroptions)

### bb.log.info

---
Prints the `message` to stderr with `[INFO] ` prefix

#### Example

```bash
# Prints `[INFO] Hello there` to stderr
bb log.info "Hello there"
```

#### Arguments

* **$1** (string): `message` Message to print

#### Exit codes

* **0**: if successful

### bb.log.warn

---
Prints the `message` to stderr with `[WARNING] ` prefix in yellow text

#### Example

```bash
# Prints `[WARNING] Hello there` to stderr
bb log.warn "Hello there"
```

#### Arguments

* **$1** (string): `message` Message to print

#### Exit codes

* **0**: if successful

### bb.log.warning

---
Prints the `message` to stderr with `[WARNING] ` prefix in yellow text

#### Example

```bash
# Prints `[WARNING] Hello there` to stderr
bb log.warning "Hello there"
```

#### Arguments

* **$1** (string): `message` Message to print

#### Exit codes

* **0**: if successful

### bb.log.error

---
Prints the `message` to stderr with `[ERROR] ` prefix in red text

#### Example

```bash
# Prints `[ERROR] Hello there` to stderr
bb log.error "Hello there"
```

#### Arguments

* **$1** (string): `message` Message to print

#### Exit codes

* **0**: if successful

### bb.log.title

---
Prints the `message` to stderr in big title letters

#### Example

```bash
# Prints the following to stderr:
#  _   _      _ _         _   _
# | | | | ___| | | ___   | |_| |__   ___ _ __ ___
# | |_| |/ _ \ | |/ _ \  | __| '_ \ / _ \ '__/ _ \
# |  _  |  __/ | | (_) | | |_| | | |  __/ | |  __/
# |_| |_|\___|_|_|\___/   \__|_| |_|\___|_|  \___|
#
bb log.title "Hello there"
```

#### Arguments

* **$1** (string): `message` Message to print

#### Exit codes

* **0**: if successful

### bb.log.header

---
Prints the `message` to stderr in header letters

#### Example

```bash
# Prints the following to stderr:
#  _  _     _ _       _   _
# | || |___| | |___  | |_| |_  ___ _ _ ___
# | __ / -_) | / _ \ |  _| ' \/ -_) '_/ -_)
# |_||_\___|_|_\___/  \__|_||_\___|_| \___|
#
bb log.header "Hello there"
```

#### Arguments

* **$1** (string): `message` Message to print

#### Exit codes

* **0**: if successful

### bb.log.mocking

---
Prints the `message` to stderr in mocking letters

#### Example

```bash
# Prints the following to stderr:
# hElLo tHeRe
bb log.header "hello there"
```

#### Arguments

* **$1** (string): `message` Message to print

#### Exit codes

* **0**: if successful

### bb.log.color

---
Prints the `message` in the desired color. Use `bb log.color.options` to see available colors

#### Example

```bash
# Prints `Hello there` in blue
bb log.color blue "Hello there"
```

#### Arguments

* **$1** (string): `color` Color to print in
* **$2** (string): `message` Message to print

#### Exit codes

* **0**: if successful

### bb.log.color.code

---
Returns the formatted ANSI escape code for the specified `color`

#### Example

```bash
# Prints `'\e[0;31m'`
bb log.color.code red
```

#### Arguments

* **$1** (string): `color` Color to print ANSI escape code for

#### Exit codes

* **0**: if successful

### bb.log.color.options

---
Prints a list of colors supported by `bb log.color.code` and transitively by `bb log.color`

#### Example

```bash
# Prints:
# black
# red
# green
# yellow
# blue
# magenta
# cyan
# white
bb log.color.options
```

#### Exit codes

* **0**: if successful

