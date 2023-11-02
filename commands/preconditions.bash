#!/bin/bash

# Checks if the `VAR_NAME` is null (as defined by bash conditional for `-z` and `-n`) and returns if not null.
# If `VAR_NAME` is null: print `ERROR_MSG` if provided, otherwise print a default error message.
#
# Usage:
# 	CI::PRECONDITIONS::not_null SOME_VARIABLE "You must set 'SOME_VARIABLE'"
#		=>  You must set 'SOME_VARIABLE'
bb.preconditions.not_null() {
	local VAR_NAME="$1"
	local ERROR_MSG="$2"
	if [ -z "$ERROR_MSG" ]; then ERROR_MSG="Expected [$VAR_NAME] to have value, but was empty."; fi
	if [ -n "${!VAR_NAME}" ]; then return; fi

	bb.log.error "Precondition failure: $ERROR_MSG"
	return 1
}

# Returns...
# - 0 if command is found and is a command (file type)
# - 1 if command arg is not provided
# - 127 if command not found as a file type
bb.preconditions.has_command() {
	local cmd="$1"
	bb.preconditions.not_null cmd || return $?
	[[ $(type -t "$1") == "file" ]] && return 0
	return 127
}

bb.preconditions.require_command() {
	local cmd="$1"
	bb.preconditions.has_command "$cmd"
	local exit_code=$?
	if [ "$exit_code" != 0 ]; then
	bb.log.error "Command not found: $cmd"
		return $exit_code
	fi
}

bb.preconditions.require_file() {
	local filepath="$1"
	bb.preconditions.not_null filepath || return $?
	if [ -f "$filepath" ]; then return; fi
	bb.log.error "Precondition failed: Expected file at $filepath but is missing."
	return 1
}
