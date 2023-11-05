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
	_bb.docs.handle_usage
	local bash_dir="$1"
	local output_dir="$2"
	bb.preconditions.not_null bash_dir || return $?
	bb.preconditions.not_null output_dir || return $?
	bb.preconditions.require_command shdoc || return $?
	mkdir -p "$output_dir"
	for bash_file in "$bash_dir"/*.bash; do
		bb.log.info "Generating docs for $bash_file"
		local filename
		filename=$(bb.io.without_last_extension "$bash_file")
		filename=$(basename "$filename")
		shdoc < "$bash_file" > "${output_dir}/${filename}.md"
	done
}

# @description
# ---
# Prints out the docs of a function.
#
# @example
# _bb.docs.usage "${BASH_SOURCE[0]}" "${FUNCNAME[0]}"
_bb.docs.for_function() {
	local script="$1"
	local current_function="$2"
	local comments=""

	#echo "WAHT ${FUNCNAME[0]} ${FUNCNAME[1]} ${FUNCNAME[2]}"

	while IFS= read -r line; do
		if [[ "$line" =~ ^$current_function\(\) ]]; then
			break
		fi

		if [[ "$line" =~ ^\# ]]; then
			comments+="${line#*#}"$'\n'
		elif [[ ! "$line" =~ ^[[:space:]]*$ ]]; then
			comments=""
		fi
	done < "$script"

	echo "$comments"
}

# @internal
_bb.docs.handle_usage() {
	for arg in ${BASH_ARGV[@]}; do
		if [[ $arg == "-h" ]] || [[ $arg == "--help" ]]; then
			local docs
			docs=$(_bb.docs.for_function "${BASH_SOURCE[1]}" "${FUNCNAME[1]}")
			echo -e "$docs" | sed -E 's/^\s*//g' | # remove leading whitespace
				sed -E 's/(@\w+\s?)/\U\1/g' |         # lines starting with "@" split and capitalize
				sed -E '/^[^@]/s/^/\t/' |             # add tabs to lines without "@"
				sed -e 's/^@//'                       # remove leading "@"
			exit 0
		fi
	done
}

# @internal
bb.docs.markdown_links() {
	for f in $(ls -1 commands); do
		# Print link to file docs
		echo "$f" | sed -E 's/\.bash//g' |       # strip the .bash suffix
			sed -E 's/^(.*)/ - [\1](docs\/\1\.md)/' # convert to markdown link
		# print each function link
		grep -oP '^[^_][a-zA-Z0-9\._]*\(\)' "commands/$f" | # find all the functions in the script file that arent internal
			sed -E 's/\(\)//g' |                               # remove the trailing "()"
			sed -E 's/bb\./   - /g'                            # remove the "bb." prefix, add the indented list
	done
}
