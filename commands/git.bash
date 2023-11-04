#!/bin/bash

# @description
# ---
# Prints the best ref possible for the current HEAD: Git tag if available, or the branch name if available, or the SHA.
#
# Source: https://stackoverflow.com/a/55276236
#
# @example
# # prints `main`, the current branch
# bb git.get_ref
#
# @exitcode 0 if successful
bb.git.get_ref() {
	_bb.docs.handle_usage
	bb.preconditions.require_command git || return $?
	git describe --tags --exact-match 2> /dev/null ||
		git symbolic-ref -q --short HEAD ||
		git rev-parse HEAD
}

# @description
# ---
# Prints the most recently created tag according to the git history
#
# @example
# # prints `v1.0.0`
# bb git.last_tag
#
# @exitcode 0 if successful
bb.git.last_tag() {
	_bb.docs.handle_usage
	git describe --tags --abbrev=0
}

# @description
# ---
# Expands a git short sha into its full form.
#
# If the `repo_url` doesnt match the current directory, this function will attempt to expand the SHA remotely which may
# require a full git clone which can be slow on large repos.  If you already have the repo cloned, using
# `git rev-parse <short-sha>` directly is faster.
#
# @example
# # prints `25291a8fe1aa01cf105be0b9516b3de2a7ebe118`
# bb git.remote.expand_sha 25291a8fe https://github.com/scottTomaszewski/bashbox/
#
# @arg $1 string `short_sha` Git short SHA
# @arg $2 string `repo_url` Url to the git repo
#
# @exitcode 0 if successful
bb.git.remote.expand_sha() {
	_bb.docs.handle_usage
	local short_sha="$1"
	local repo_url="$2"
	bb.preconditions.not_null short_sha || return $?
	bb.preconditions.not_null repo_url || return $?

	local temp_repo_dir="bb-expand-sha-temp"
	local curr_remote_url=$(git config --get remote.origin.url)

	# make sure we cleanup afterwards
	local og_dir="$(pwd)"
	trap 'cd "$og_dir" && rm -rf "${og_dir}/${temp_repo_dir}" && rm -rf "${og_dir}/${temp_repo_dir}.txt"' RETURN

	# If we are currently in the correct repo, return rev-parse
	if [ "$curr_remote_url" == "$repo_url" ]; then
		local revparse_output_file="${temp_repo_dir}.txt"
		git rev-parse "$short_sha" &> "$revparse_output_file"
		local revparse_return_code=$?

		# If no error, return. Otherwise current repo is a shallow clone, continue with full clone
		if [ $revparse_return_code == 0 ]; then
			cat "$revparse_output_file"
			return
		fi
	fi

	# Attempt to find the commit with ls-remote
	local expanded
	expanded=$(git ls-remote "$repo_url" | awk '{ print $1 }' | grep "$short_sha" | head -n 1)
	if [ -n "$expanded" ]; then
		echo "$expanded"
		return
	fi

	# Forced to deep clone to grab short sha objects
	local clone_output_file="${temp_repo_dir}.txt"
	git clone "$repo_url" "$temp_repo_dir" &> "$clone_output_file"
	local clone_return_code=$?

	# If clone failed, print and error out
	if [ $clone_return_code != 0 ]; then
		cat "$clone_output_file"
		return $clone_return_code
	fi

	# Rev-parse the sha and cleanup
	cd "$temp_repo_dir"
	git rev-parse "$short_sha"
}

# @description
# ---
# "Clones" a repo at a specific `ref` with a depth of 1.
#
# - The `ref` can be a branch name, tag, commit SHA, or commit short SHA.
# - The repo will be in a "detached HEAD" state.
#
# @example
# # shallow clones repo at short SHA
# bb git.clone.shallow 25291a8fe https://github.com/scottTomaszewski/bashbox/
# &nbsp;
# # shallow clones repo at full SHA
# bb git.clone.shallow 25291a8fe1aa01cf105be0b9516b3de2a7ebe118 https://github.com/scottTomaszewski/bashbox/
# &nbsp;
# # shallow clones repo at tag
# bb git.clone.shallow v0.0.1 https://github.com/scottTomaszewski/bashbox/
# &nbsp;
# # shallow clones repo at branch
# bb git.clone.shallow main https://github.com/scottTomaszewski/bashbox/
# &nbsp;
# # shallow clones repo at branch into directory `something`
# bb git.clone.shallow main https://github.com/scottTomaszewski/bashbox/ "something"
#
# @arg $1 string `short_sha` Git short SHA
# @arg $2 string `repo_url` Url to the git repo
# @arg $3 string `repo_dir` [Optional] Directory to clone the repo into. Defaults to repo name.
#
# @exitcode 0 if successful
bb.git.clone.shallow() {
	_bb.docs.handle_usage
	local ref="$1"
	local repo_url="$2"
	local repo_dir="$3"

	bb.preconditions.not_null repo_url || return $?
	bb.preconditions.not_null ref || return $?

	if [ -z "$repo_dir" ]; then
		repo_dir="$(basename "$repo_url" .git)"
	fi

	# ensure proper dir after function execution
	local og_dir="$(pwd)"
	trap 'cd "$og_dir"' RETURN

	# attempt to clone the branch/tag
	local clone_successful=0
	git -c advice.detachedHead=false clone --depth=1 --branch="$ref" "$repo_url" "$repo_dir" &> clone_output.txt || clone_successful=$?
	local clone_output
	clone_output=$(cat clone_output.txt)
	rm clone_output.txt

	if [ "$clone_successful" == 0 ]; then
		printf "%s\n" "$clone_output"

	# If invalid, assume ref is a commit hash and attempt a fetch/checkout
	elif grep -q "not found in upstream origin" <(echo "$clone_output"); then
		bb.log.warn "Could not directly clone [$ref] (not branch nor tag). Attempting to fetch/checkout."
		mkdir "$repo_dir"
		cd "$repo_dir"
		git init 1>&2
		git remote add origin "$repo_url"
		local fetch_return_code=0
		git fetch --depth 1 origin "$ref" &> fetch_output.txt || fetch_return_code=$?
		local fetch_output=$(cat fetch_output.txt)
		rm fetch_output.txt

		if [ "$fetch_return_code" != 0 ]; then
			# Attempt to find the short SHA with ls-remote
			bb.log.warn "Could not fetch/checkout [$ref] (must be short SHA). Attempting to expand SHA."
			local expanded
			expanded=$(_bb.git.remote.expand_sha_with_ls_remote "$ref" "$repo_url")
			#expanded=$(git ls-remote "$repo_url" | awk '{ print $1 }' | grep "$ref" | head -n 1)

			if [ -z "$expanded" ]; then
				bb.log.warn "Could not find special pointer to the ref [${ref}]. Cloning full repo to find ref."

				# clean up old attempts,
				cd ..
				rm -rf "$repo_dir"

				# clone repo, checkout ref
				git clone "$repo_url" "$repo_dir"
				cd "$repo_dir"
				git -c advice.detachedHead=false checkout "$ref"
				return 0
			fi

			# Attempt to fetch the expanded (full) SHA
			git fetch --depth 1 origin "$expanded"
		fi

		git -c advice.detachedHead=false checkout FETCH_HEAD

	# Otherwise print error and exit
	else
		printf "%s\n" "$clone_output"
		cd "$og_dir"
		return $clone_successful
	fi
}

# @internal
_bb.git.remote.expand_sha_with_ls_remote() {
	_bb.docs.handle_usage
	local short_sha="$1"
	local repo_url="$2"
	bb.preconditions.not_null short_sha || return $?
	bb.preconditions.not_null repo_url || return $?

	local expanded
	expanded=$(git ls-remote "$repo_url" | awk '{ print $1 }' | grep "$short_sha" | head -n 1)
	if [ "$expanded" != "" ]; then
		echo "$expanded"
		return
	fi
	return 1
}
