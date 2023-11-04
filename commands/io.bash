#!/bin/bash

# @description
# ---
# If `filename_or_var` is a filepath and exists, runs `cat` on the file.  Otherwise, runs `echo` on `$filename_or_var`
#
# For commands that only take a file, can be useful to do the following (where `INPUT` is either a filepath or string):
# 		`command -f <(bb io.file_or_var "$INPUT")`
#
# @arg $1 string `filename_or_var` A file path or content
#
# @exitcode 0 if successful
# @exitcode 1 if filename_or_var not provided
bb.io.file_or_var() {
	_bb.docs.handle_usage
	local filename_or_var
	filename_or_var=$(_bb.io.param_or_piped "$@")
	bb.preconditions.not_null filename_or_var || return $?
	if [ -f "$filename_or_var" ]; then
		cat "$filename_or_var"
		return
	fi
	echo "$filename_or_var"
}

# @description
# ---
# Removes all extensions from a file path.
#
# @example
# # prints `filename`
# bb io.without_extensions "filename.tar.gz"
#
# @arg $1 string `filename` A file name/path
#
# @exitcode 0 if successful
# @exitcode 1 if filename not provided
bb.io.without_extensions() {
	_bb.docs.handle_usage
	local filename
	filename=$(_bb.io.param_or_piped "$@")
	bb.preconditions.not_null filename || return $?
	echo "${filename%%.*}"
}

# @description
# ---
# Removes the last extensions from a file path
#
# @example
# # prints `filename.tar`
# bb io.without_last_extension "filename.tar.gz"
#
# @arg $1 string `filename` A file name/path
#
# @exitcode 0 if successful
# @exitcode 1 if filename not provided
bb.io.without_last_extension() {
	_bb.docs.handle_usage
	local filename
	filename=$(_bb.io.param_or_piped "$@")
	bb.preconditions.not_null filename || return $?
	echo "${filename%.*}"
}

# @description
# ---
# Returns all extensions of a file path
#
# @example
# # prints `tar.gz`
# bb io.extensions "filename.tar.gz"
#
# @arg $1 string `filename` A file name/path
#
# @exitcode 0 if successful
# @exitcode 1 if filename not provided
bb.io.extensions() {
	_bb.docs.handle_usage
	local filename
	filename=$(_bb.io.param_or_piped "$@")
	bb.preconditions.not_null filename || return $?
	echo "${filename#*.}"
}

# @description
# ---
# Returns last extension of a file path
#
# @example
# # prints `gz`
# bb io.last_extension "filename.tar.gz"
#
# @arg $1 string `filename` A file name/path
#
# @exitcode 0 if successful
# @exitcode 1 if filename not provided
bb.io.last_extension() {
	_bb.docs.handle_usage
	local filename
	filename=$(_bb.io.param_or_piped "$@")
	bb.preconditions.not_null filename || return $?
	echo "${filename##*.}"
}

# @description
# ---
# Prints the full path to a file, handling a few special cases.
# Can be especially useful to get a script's directory with `bb io.full_dir_of "${BASH_filepath[0]}"` inside the script
#
# Source: https://stackoverflow.com/a/246128
#
# @example
# # prints something like `/home/scott.tomaszewski/code/personal/bashbox`
# bb io.full_dir_of "."
#
# @arg $1 string `filename` A file name
#
# @exitcode 0 if successful
# @exitcode 1 if filename not provided
bb.io.full_dir_of() {
	_bb.docs.handle_usage
	local filename
	filename=$(_bb.io.param_or_piped "$@")
	bb.preconditions.not_null filepath || return $?
	local directory
	while [ -L "$filepath" ]; do # resolve $filepath until the file is no longer a symlink
		directory=$(cd -P "$(dirname "$filepath")" > /dev/null 2>&1 && pwd)
		filepath=$(readlink "$filepath")
		[[ $filepath != /* ]] && filepath=$directory/$filepath # if $filepath was a relative symlink, we need to resolve it relative to the path where the symlink file was located
	done
	directory=$(cd -P "$(dirname "$filepath")" > /dev/null 2>&1 && pwd)
	echo "$directory"
}

# @internal
#
# @description returns the piped input if available, otherwise the arg
# TODO - consider making this public...
_bb.io.param_or_piped() {
	local input
	# Check if an argument was provided, and if not, read from stdin (pipe)
	if [ $# -eq 0 ]; then
		input=$(cat)
	else
		input="$1"
	fi
	echo "$input"
}
