# If `file_or_var` is a filepath and exists, runs `cat` on the file.  Otherwise, runs `echo` on `$filename_or_var`
# For commands that only take a file, can be useful to do the following (where `INPUT` is either a filepath or string):
# 		command -f <(bb io.file_or_var "$INPUT")
bb.io.file_or_var() {
	local filename_or_var="$1"
	bb.preconditions.not_null filename_or_var || return $?
	if [ -f "$filename_or_var" ]; then
		cat "$filename_or_var"
		return
	fi
	echo "$filename_or_var"
}
