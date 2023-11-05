#!/bin/bash

# @description
# ---
# Returns a non-zero exit code and prints error if `var_name` does not resolve to a non-empty value.
#
# IMPORTANT: The `var_name` arg is just the *name* not the expanded variable.  This allows for a more useful
# error message
#
# @example
# # Returns exit code 127 and prints "[ERROR] Expected [fake_var] to have value, but was empty." to stderr
# bb preconditions.not_null "fake_var"
# #
# # Returns exit code 127 and prints "[ERROR] Missing var!" to stderr
# bb preconditions.not_null "fake_var" "Missing var!"
# #
# # Common pattern to print error and exit function
# bb preconditions.not_null "fake_var" || return $?
#
# @arg $1 string `var_name` Variable name to check
# @arg $2 string `error_message` (Optional) Error message to print if `var_name` value is empty. Defaults to
# "Expected [$var_name] to have value, but was empty."
#
# @exitcode 0 if successful
# @exitcode 1 if `var_name` arg not provided
# @exitcode 127 if `var_name` value is empty
bb.preconditions.not_null() {
	_bb.docs.handle_usage
	local var_name="$1"
	local error_message="$2"
	if [ -z "$error_message" ]; then error_message="Expected [$var_name] to have value, but was empty."; fi
	if [ -z "$var_name" ]; then bb.log.error "Expected [var_name] to have value, but was empty."; return 1; fi
	if [ -n "${!var_name}" ]; then return; fi
	bb.log.error "Precondition failure: $error_message"
	return 127
}

# @description
# ---
# Returns a non-zero exit code if `command` is not available.
#
# @example
# # Returns exit code 127
# bb preconditions.require_command fake_command
#
# @arg $1 string `command` Command to check availability of
#
# @exitcode 0 if successful
# @exitcode 1 if `command` arg not provided
# @exitcode 127 if command not found
bb.preconditions.has_command() {
	_bb.docs.handle_usage
	local command="$1"
	bb.preconditions.not_null command || return $?
	[[ $(type -t "$1") == "file" ]] && return 0
	return 127
}

# @description
# ---
# Returns a non-zero exit code and prints error if `command` is not available.
#
# @example
# # Returns exit code 127 and prints "[ERROR] Command not found: fake_command" to stderr
# bb preconditions.require_command fake_command
# #
# # Common pattern to print error and exit function
# bb preconditions.require_command fake_command || return $?
#
# @arg $1 string `command` Command to check availability of
#
# @exitcode 0 if successful
# @exitcode 1 if `command` arg not provided
# @exitcode 127 if command not found
bb.preconditions.require_command() {
	_bb.docs.handle_usage
	local command="$1"
	bb.preconditions.has_command "$command"
	local exit_code=$?
	if [ "$exit_code" != 0 ]; then
		bb.log.error "Command not found: $command"
		return $exit_code
	fi
}

# @description
# ---
# Returns a non-zero exit code and prints error if `filepath` is not found.
#
# @example
# # Returns exit code 127 and prints "[ERROR] Precondition failed: Expected file at fake_file but is missing." to stderr
# bb preconditions.require_file fake_file
# #
# # Common pattern to print error and exit function
# bb preconditions.require_file fake_file || return $?
#
# @arg $1 string `filepath` File path to check availability of
#
# @exitcode 0 if successful
# @exitcode 1 if `filepath` arg not provided
# @exitcode 127 if filepath not found
bb.preconditions.require_file() {
	_bb.docs.handle_usage
	local filepath="$1"
	bb.preconditions.not_null filepath || return $?
	if [ -f "$filepath" ]; then return; fi
	bb.log.error "Precondition failed: Expected file at $filepath but is missing."
	return 127
}
