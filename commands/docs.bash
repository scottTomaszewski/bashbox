#!/bin/bash

# @description
# ---
# Generates markdown documentation for bash scripts using shdoc
#
# @arg $1 string `bash_dir` File path to a directory of bash scripts
# @arg $2 string `output_dir` File path to a directory to dump the markdown files
#
# @exitcode 0 if successful
# @exitcode 1 if args not provided or `shdoc` is not found
bb.docs.generate_for_bash() {
	local bash_dir="$1"
	local output_dir="$2"
	bb.preconditions.not_null bash_dir || return $?
	bb.preconditions.not_null output_dir || return $?
	bb.preconditions.require_command shdoc || return $?
	mkdir -p "$output_dir"
	for bash_file in "$bash_dir"/*.bash; do
		bb.log.info "Generating docs for $bash_file"
		local filename
		filename=$(bb.io.without_extensions "$bash_file")
		filename=$(basename "$filename")
		shdoc < "$bash_file" > "${output_dir}/${filename}.md"
	done
}
