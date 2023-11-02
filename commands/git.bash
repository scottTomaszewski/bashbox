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
    bb.preconditions.require_command git || return $?
    git describe --tags --exact-match 2> /dev/null \
      || git symbolic-ref -q --short HEAD \
      || git rev-parse HEAD
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
# @exitcode 0 if successful
bb.git.remote.expand_sha() {
	local short_sha="$1"
	local repo_url="$2"
	bb.preconditions.not_null short_sha || return $?
	bb.preconditions.not_null repo_url || return $?

	local temp_repo_dir="bb-expand-sha-temp"
	local curr_remote_url=$(git config --get remote.origin.url)

	# make sure we cleanup afterwards
	local og_dir="$(pwd)"
	trap 'cd "$og_dir" && rm -rf "${og_dir}/${temp_repo_dir}" && rm -rf "${og_dir}/${temp_repo_dir}.txt"'  RETURN

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

# "Clones" a repo as a specific REF with a depth of 1.  The REF can be a branch name, tag, or commit hash. Optional
# `REPO_DIR` param to specify the directory to use as the shallow-clone destination. Without this param, standard git
# behavior will carry out (uses the repo name as the destination dir name)
# Note: If successful, the repo will be in a "detached HEAD" state. The `SHALLOW_CLONE_REPO_DIR` variable will
# be set with the absolute path of the repo.
#
# USAGE
#   bb.git.clone.shallow git@gitlab.com:finxact/engineering/core/code-gen.git 05347c0ed748825d2a28ba41a7f17550acee70c4
#   bb.git.clone.shallow git@gitlab.com:finxact/engineering/core/code-gen.git v1.33.0
#   bb.git.clone.shallow git@gitlab.com:finxact/engineering/core/code-gen.git master
#   bb.git.clone.shallow git@gitlab.com:finxact/engineering/core/code-gen.git 05347c0ed
bb.git.clone.shallow() {
    local REF="$1"
    local REPO_URL="$2"
    local REPO_DIR="$3"

    bb.preconditions.not_null REPO_URL || return $?
    bb.preconditions.not_null REF || return $?

    if [ -z "$REPO_DIR" ]; then
        REPO_DIR="$(basename "$REPO_URL" .git)"
    fi
    export SHALLOW_CLONE_REPO_DIR="$(pwd)/${REPO_DIR}"
    git config --global advice.detachedHead false

    # ensure proper dir after function execution
    local OG_DIR="$(pwd)"
    trap 'cd "$OG_DIR"' RETURN

    # attempt to clone the branch/tag
    local CLONE_SUCCESS=0
    git clone --depth=1 --branch="$REF" "$REPO_URL" "$REPO_DIR" &> clone_output.txt || CLONE_SUCCESS=$?
    local CLONE_OUTPUT=$(cat clone_output.txt)
    rm clone_output.txt

    if [ "$CLONE_SUCCESS" == 0 ]; then
        printf "%s\n" "$CLONE_OUTPUT"

    # If invalid, assume REF is a commit hash and attempt a fetch/checkout
    elif grep -q "not found in upstream origin" <(echo "$CLONE_OUTPUT"); then
        bb.log.warn "Could not directly clone [$REF] (not branch nor tag). Attempting to fetch/checkout instead"
        mkdir "$REPO_DIR"
        cd "$REPO_DIR"
        git init 1>&2
        git remote add origin "$REPO_URL"
        local FETCH_RETURN_CODE=0
        git fetch --depth 1 origin "$REF" &> fetch_output.txt || FETCH_RETURN_CODE=$?
        local FETCH_OUTPUT=$(cat fetch_output.txt)
        rm fetch_output.txt

        if [ "$FETCH_RETURN_CODE" != 0 ]; then
            # Attempt to find the short SHA with ls-remote
            bb.log.warn "Could not fetch/checkout $REF (must be short SHA). Attempting to expand SHA."
            EXPANDED=$(git ls-remote "$REPO_URL" | awk '{ print $1 }' | grep "$REF" | head -n 1)

            if [ -z "$EXPANDED" ]; then
                bb.log.warn "Could not find special pointer to the ref ${REF}. Cloning full repo to find ref."

                # clean up old attempts, clone repo, checkout ref
                cd ..
                rm -rf "$REPO_DIR"
                git clone "$REPO_URL" "$REPO_DIR"
                cd "$REPO_DIR"
                git checkout "$REF"
                return 0
            fi

            # Attempt to fetch the expanded (full) SHA
            git fetch --depth 1 origin "$EXPANDED"
        fi

        git checkout FETCH_HEAD

    # Otherwise print error and exit
    else
        printf "%s\n" "$CLONE_OUTPUT"
        cd "$OG_DIR"
        return $CLONE_SUCCESS
    fi
}

_bb.git.remote.expand_sha_with_ls_remote() {
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
