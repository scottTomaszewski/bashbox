#!/bin/bash

# @description
# ---
# Prints the `message` to stderr with `[INFO] ` prefix
#
# @example
# # Prints `[INFO] Hello there` to stderr
# bb log.info "Hello there"
#
# @arg $1 string `message` Message to print
#
# @exitcode 0 if successful
bb.log.info() {
	_bb.docs.handle_usage
	local message
	message=$(_bb.io.param_or_piped "$@")
	echo -e "[INFO] $message" >&2
}

# @description
# ---
# Prints the `message` to stderr with `[WARNING] ` prefix in yellow text
#
# @example
# # Prints `[WARNING] Hello there` to stderr
# bb log.warn "Hello there"
#
# @arg $1 string `message` Message to print
#
# @exitcode 0 if successful
bb.log.warn() {
	_bb.docs.handle_usage
	bb.log.warning "$@"
}

# @description
# ---
# Prints the `message` to stderr with `[WARNING] ` prefix in yellow text
#
# @example
# # Prints `[WARNING] Hello there` to stderr
# bb log.warning "Hello there"
#
# @arg $1 string `message` Message to print
#
# @exitcode 0 if successful
bb.log.warning() {
	_bb.docs.handle_usage
	local message
	message=$(_bb.io.param_or_piped "$@")
	bb.log.color yellow "[WARNING] $message"
}

# @description
# ---
# Prints the `message` to stderr with `[ERROR] ` prefix in red text
#
# @example
# # Prints `[ERROR] Hello there` to stderr
# bb log.error "Hello there"
#
# @arg $1 string `message` Message to print
#
# @exitcode 0 if successful
bb.log.error() {
	_bb.docs.handle_usage
	local message
	message=$(_bb.io.param_or_piped "$@")
	bb.log.color red "[ERROR] $message"
}

# @description
# ---
# Prints the `message` to stderr in big title letters
#
# @example
# # Prints the following to stderr:
# #  _   _      _ _         _   _
# # | | | | ___| | | ___   | |_| |__   ___ _ __ ___
# # | |_| |/ _ \ | |/ _ \  | __| '_ \ / _ \ '__/ _ \
# # |  _  |  __/ | | (_) | | |_| | | |  __/ | |  __/
# # |_| |_|\___|_|_|\___/   \__|_| |_|\___|_|  \___|
# #
# bb log.title "Hello there"
#
# @arg $1 string `message` Message to print
#
# @exitcode 0 if successful
bb.log.title() {
	_bb.docs.handle_usage
	local message
	message=$(_bb.io.param_or_piped "$@")
	bb.preconditions.require_command figlet
	figlet >&2 "$message"
}

# @description
# ---
# Prints the `message` to stderr in header letters
#
# @example
# # Prints the following to stderr:
# #  _  _     _ _       _   _
# # | || |___| | |___  | |_| |_  ___ _ _ ___
# # | __ / -_) | / _ \ |  _| ' \/ -_) '_/ -_)
# # |_||_\___|_|_\___/  \__|_||_\___|_| \___|
# #
# bb log.header "Hello there"
#
# @arg $1 string `message` Message to print
#
# @exitcode 0 if successful
bb.log.header() {
	_bb.docs.handle_usage
	local message
	message=$(_bb.io.param_or_piped "$@")
	bb.preconditions.require_command figlet
	figlet -f small "$message" >&2
}

# @description
# ---
# Prints the `message` to stderr in mocking letters
#
# @example
# # Prints the following to stderr:
# # hElLo tHeRe
# bb log.header "hello there"
#
# @arg $1 string `message` Message to print
#
# @exitcode 0 if successful
bb.log.mocking() {
	_bb.docs.handle_usage
	local message
	message=$(_bb.io.param_or_piped "$@")
	echo -e "$message" | sed 's/\(.\)\(.\)\?/\1\u\2/g'
}

# @description
# ---
# Prints the `message` in the desired color. Use `bb log.color.options` to see available colors
#
# @example
# # Prints `Hello there` in blue
# bb log.color blue "Hello there"
#
# @arg $1 string `color` Color to print in
# @arg $2 string `message` Message to print
#
# @exitcode 0 if successful
bb.log.color() {
	_bb.docs.handle_usage
	local color="$1"
	bb.preconditions.not_null color || return $?
	local message="${@:2}"
	local color_code=$(bb.log.color.code "$color")
	local txtreset="$(tput sgr 0 2> /dev/null || echo '\e[0m')"
	echo -e "${color_code}${message}${txtreset}" >&2
}

# @description
# ---
# Returns the formatted ANSI escape code for the specified `color`
#
# @example
# # Prints `'\e[0;31m'`
# bb log.color.code red
#
# @arg $1 string `color` Color to print ANSI escape code for
#
# @exitcode 0 if successful
bb.log.color.code() {
	_bb.docs.handle_usage
	local color
	color=$(_bb.io.param_or_piped "$@")
	bb.preconditions.not_null color || return $?

	# Text colors
	local TXTBLK="$(tput setaf 0 2> /dev/null || echo '\e[0;30m')"
	local TXTRED="$(tput setaf 1 2> /dev/null || echo '\e[0;31m')"
	local TXTGRN="$(tput setaf 2 2> /dev/null || echo '\e[0;32m')"
	local TXTYLW="$(tput setaf 3 2> /dev/null || echo '\e[0;33m')"
	local TXTBLU="$(tput setaf 4 2> /dev/null || echo '\e[0;34m')"
	local TXTPUR="$(tput setaf 5 2> /dev/null || echo '\e[0;35m')"
	local TXTCYN="$(tput setaf 6 2> /dev/null || echo '\e[0;36m')"
	local TXTWHT="$(tput setaf 7 2> /dev/null || echo '\e[0;37m')"

	case "$color" in
	black) local COLOR_START="$TXTBLK" ;;
	red) local COLOR_START="$TXTRED" ;;
	green) local COLOR_START="$TXTGRN" ;;
	yellow) local COLOR_START="$TXTYLW" ;;
	blue) local COLOR_START="$TXTBLU" ;;
	magenta) local COLOR_START="$TXTPUR" ;;
	cyan) local COLOR_START="$TXTCYN" ;;
	white) local COLOR_START="$TXTWHT" ;;
	*) local COLOR_START="" ;;
	esac
	echo "$COLOR_START"
}

# @description
# ---
# Prints a list of colors supported by `bb log.color.code` and transitively by `bb log.color`
#
# @example
# # Prints:
# # black
# # red
# # green
# # yellow
# # blue
# # magenta
# # cyan
# # white
# bb log.color.options
#
# @exitcode 0 if successful
bb.log.color.options() {
	_bb.docs.handle_usage
	echo "black"
	echo "red"
	echo "green"
	echo "yellow"
	echo "blue"
	echo "magenta"
	echo "cyan"
	echo "white"
}
