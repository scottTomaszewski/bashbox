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
	local filename_or_var="$1"
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
	local filename="$1"
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
	local filename="$1"
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
	local filename="$1"
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
	local filename="$1"
	bb.preconditions.not_null filename || return $?
	echo "${filename##*.}"
}
