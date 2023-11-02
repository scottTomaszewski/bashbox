#!/bin/bash

# @description
#
# @arg $1 string `filename_or_var` A file path or content
#
# @exitcode 0 if successful
# @exitcode 1 if filename_or_var not provided
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
