#!/bin/bash

# @description If `filename_or_var` is a filepath and exists, runs `cat` on the file.  Otherwise, runs `echo` on `$filename_or_var`
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

bb.io.without_extensions() {
	local filename="$1"
	bb.preconditions.not_null filename || return $?
	echo "${filename%%.*}"
}

bb.io.without_last_extension() {
	# todo
	return
}

bb.io.extensions() {
	# todo
	return
}

bb.io.last_extension() {
	# todo
	return
}
