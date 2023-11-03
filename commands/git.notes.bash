#!/bin/bash

# @description
# ---
# Fetches git notes from remote
#
# @example
# bb git.notes.fetch
#
# @exitcode 0 if successful
bb.git.notes.fetch() {
	git fetch --force origin refs/notes/*:refs/notes/*
}

# @description
# ---
# Fetches git notes from remote, then runs git log
#
# @example
# bb git.notes.log
#
# @exitcode 0 if successful
bb.git.notes.log() {
	git fetch --force origin refs/notes/*:refs/notes/*
	git log
}

# @description
# ---
# Retrieves the value for a specified `key` in the git notes of the specified `ref`.
#
# If there are multiple lines in the git notes with the same key, the value of the last one will be returned.  If the
# git repo is a shallow clone, this function will `fetch --unshallow` to attempt to find the `ref`.
#
# @example
# # this will get the value of key `metadata` in the git notes of commit ec95e1f0d6e06ba7e51e8c5573b14394c8a1fb55
# bb git.notes.kv.get metadata ec95e1f0d6e06ba7e51e8c5573b14394c8a1fb55
# &nbsp;
# # this will get the value of key `metadata` in the git notes of HEAD and defaults to `{"foo":"bar"}` if not found
# bb git.notes.kv.get metadata ec95e1f0d6e06ba7e51e8c5573b14394c8a1fb55 "{\"foo\":\"bar\"}"
#
# @arg $1 string `key` Key portion of a key-value pair in git-notes entry
# @arg $2 string `ref` (Optional) Git object ref commit hash, tag, etc. Defaults to HEAD
# @arg $3 string `default_value` (Optional) Value to print if `key` is not found in git notes. Defaults to empty string
# @arg $4 string `default_message` (Optional) Message to print to stderr if default_value is used. Doesnt print if not provided.
#
# @exitcode 0 if successful
bb.git.notes.kv.get() {
	local key="$1"
	local ref="$2"
	local default_value="$3"
	local default_message="$4"

	bb.preconditions.not_null key || return $?
	if [ -z "$ref" ]; then ref="HEAD"; fi

	# Fetch latest notes, get notes for ref
	bb.git.notes.fetch
	local notes
	notes=$(git notes show "$ref" 2> /dev/null)
	local exit_code=$?

	# If the ref isnt found, might be a shallow clone?
	if [ "$exit_code" == 128 ]; then

		# Check to see if we are in a shallow clone, exit if we arent b/c ref doesnt exist
		local is_shallow
		is_shallow=$(git rev-parse --is-shallow-repository)
		if [ "$is_shallow" == "false" ]; then
			bb.log.error "Could not resolve [$ref], exiting"
			return $exit_code
		fi

		# We are in shallow clone, unshallow thyself
		bb.log.info "Could not resolve [$ref], attempting to fetch to 'unshallow' the repo."
		git fetch --unshallow -q
		exit_code=$?
		if [ "$exit_code" != 0 ]; then
			bb.log.error "Failed to unshallow the repo and cannot resolve [$ref], exiting."
			return $exit_code
		fi

		# We have unshallowed, check for ref again.
		notes=$(git notes show "$ref")
		exit_code=$?
		if [ "$exit_code" != 0 ]; then
			bb.log.error "Could not resolve [$ref], exiting"
			return $exit_code
		fi
	fi

	# At this point, `notes` should have the notes in it. Extract value for key in notes, print it
	local value=$(echo "$notes" | grep "$key=" | tail -n 1 | awk -F "=" '{ print $2 }')
	if [ -n "$value" ]; then
		echo "$value"
		return
	fi

	# Key not found in notes, handle defaults
	bb.log.warn "Could not find key [$key] on git ref [$ref]"
	if [ -n "$default_message" ]; then echo >&2 "$default_message"; fi
	echo "$default_value"
}

# @description
# ---
# Retrieves the value for a specified `key` in the git notes of the specified `ref` for the repo at `repo_url`
#
# If there are multiple lines in the git notes with the same key, the value of the last one will be returned.
#
# @example
# # Gets the value of key `metadata` in the git notes of commit `ec95e1f0d6e06ba7e51e8c5573b14394c8a1fb55` for repo `https://github.com/scottTomaszewski/bashbox/`
# bb git.notes.kv.remote.get metadata ec95e1f0d6e06ba7e51e8c5573b14394c8a1fb55 https://github.com/scottTomaszewski/bashbox/
#
# TODO - add default value support
# &nbsp;
# # this will get the value of key `metadata` in the git notes of HEAD and defaults to `{"foo":"bar"}` if not found
# bb git.notes.kv.get metadata ec95e1f0d6e06ba7e51e8c5573b14394c8a1fb55 "{\"foo\":\"bar\"}"
#
# @arg $1 string `key` Key portion of a key-value pair in git-notes entry
# @arg $2 string `ref` (Optional) Git object ref commit hash, tag, etc. Defaults to HEAD
#
# @exitcode 0 if successful
bb.git.notes.kv.remote.get() {
	# key portion of the key-value pair
	local key=$1
	# git reference object - commit hash, tag, etc
	local ref=$2
	# git repo url
	local repo_url=$3

	bb.preconditions.not_null key || return $?
	bb.preconditions.not_null ref || return $?
	bb.preconditions.not_null repo_url || return $?

	local curr_remote_url
	curr_remote_url=$(git config --get remote.origin.url)

	# If we are currently in the correct repo...
	if [ "$curr_remote_url" == "$repo_url" ]; then
		bb.git.notes.kv.get "$key" "$ref"
		return $?
	fi

	# We are not in the correct repo, forced to shallow clone. Prepare cleanup
	local temp_repo_dir="$(pwd)/ciu-notes-kv-temp"
	trap "rm -rf '$temp_repo_dir'" EXIT

	# Shallow clone the ref
	bb.git.clone.shallow "$ref" "$repo_url" "$temp_repo_dir" 1>&2
	local exit_code=$?

	# If clone failed, print and error out
	if [ $exit_code != 0 ]; then
		return $exit_code
	fi

	# Get git-note key for ref, print, return
	cd "$temp_repo_dir"
	local value
	value=$(bb.git.notes.kv.get "$key" "$ref")
	exit_code=$?
	echo -e "$value"
	return $exit_code
}

# @description
# ---
# Sets the value for a specified `key` in the git notes on `HEAD` ref and pushes the change.
#
# There is currently no guarantee of the order of keys and ordering cannot be relied on.
#
# If there are push rules for the git commit message on the repo, you will need to update the
# regex to allow for commit messages that start with `Notes \w+ by` or equivalent.
#
# @example
# # this will set the value of key `metadata` to `{"foo": "bar"}` in the git notes of `HEAD`
# bb git.notes.kv.set metadata '{"foo": "bar"}'
# &nbsp;
#
# @arg $1 string `key` Key portion of a key-value pair in git-notes entry
# @arg $2 string `value` Value to assign to `key`
# @arg $3 string `branch` (Optional) Branch to push to in case of detached HEAD.
#
# @exitcode 0 if successful
bb.git.notes.kv.set() {
	local key="$1"
	local value="$2"
	local branch=$3

	bb.preconditions.not_null key || return $?
	bb.preconditions.not_null value || return $?

	# Grab any existing notes
	bb.git.notes.fetch

	# Get existing notes, remove key entries from it, cleanup
	local other_notes=$(git notes show | grep -v "${key}=")
	if [ -n "$other_notes" ]; then
		git notes add -f -m "$other_notes"
	else
		git notes remove --ignore-missing
	fi

	git notes append -m "$key=$value"
	bb.log.info "Git notes updated to:\n$(git notes show)\n"

	if [ -n "$branch" ]; then
		git push origin refs/notes/* HEAD:$branch
		return
	fi
	git push origin refs/notes/*
}
