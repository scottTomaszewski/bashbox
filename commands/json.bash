bb.json.get() {
	local key="$1"
	local input="$2"
	bb.preconditions.not_null key || return $?
	bb.preconditions.not_null input || return $?
	bb.preconditions.require_command jq || return $?

	# messy: add trailing quote, add quote after first `.`, surround remaining `.` with quotes
	# TL;DR: `.foo.bar` becomes `."foo"."bar"`
	local jpath=$(echo "$key\"" | sed 's/^\./\."/' | sed 's/\./\"\.\"/2g')
	jq -r "$jpath // empty" <(bb.io.file_or_var "$input")
}

bb.json.get_or_default() {
	local key="$1"
	local input="$2"
	local default="$3"
	bb.preconditions.not_null key || return $?
	bb.preconditions.not_null input || return $?
	bb.preconditions.not_null default || return $?

	local value
	value=$(bb.json.get "$key" "$input")
	local exit_code="$?"
	if [ "$exit_code" != 0 ]; then
		bb.log.error "Failed to get key from input. $value"
		return "$exit_code"
	fi

	if [ -n "$value" ]; then
		echo "$value"
		return
	fi

	echo "$default"
	return
}
