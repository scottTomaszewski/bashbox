bb.json.get() {
	local key="$1"
	local input="$2"
	bb.preconditions.not_null key || return $?
	bb.preconditions.not_null input || return $?
	bb.preconditions.require_command jq || return $?

	local jpath
	jpath=$(_bb.json.as_jpath "$key")
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

bb.json.set() {
	local key="$1"
	local value="$2"
	local input="$3"
	bb.preconditions.not_null key || return $?
	bb.preconditions.not_null value || return $?
	bb.preconditions.not_null input || return $?
	bb.preconditions.require_command jq || return $?

	local jpath
	jpath=$(_bb.json.as_jpath "$key")
	jq -r --arg value "$value" "$jpath = \$value" <(bb.io.file_or_var "$input")
}

bb.json.inplace.set() {
	local key="$1"
	local value="$2"
	local input="$3"
	bb.preconditions.require_file "$input" || return $?

	local output
	output=$(bb.json.set "$key" "$value" "$input")
	local exit_code=$?
	if [ "$exit_code" != 0 ]; then
		bb.log.error "Failed to set json value (error $exit_code): $output"
		return "$exit_code"
	fi
	echo -e "$output" > "$input"
}

bb.json.set_number() {
	local key="$1"
	local value="$2"
	local input="$3"
	bb.preconditions.not_null key || return $?
	bb.preconditions.not_null value || return $?
	bb.preconditions.not_null input || return $?
	bb.preconditions.require_command jq || return $?

	local jpath
	jpath=$(_bb.json.as_jpath "$key")
	jq -r --arg value "$value" "$jpath = (\$value | tonumber)" <(bb.io.file_or_var "$input")
}

bb.json.inplace.set_number() {
	local key="$1"
	local value="$2"
	local input="$3"
	bb.preconditions.require_file "$input" || return $?

	local output
	output=$(bb.json.set_number "$key" "$value" "$input")
	local exit_code=$?
	if [ "$exit_code" != 0 ]; then
		bb.log.error "Failed to set json numeric value (error $exit_code): $output"
		return "$exit_code"
	fi
	echo -e "$output" > "$input"
}

bb.json.delete() {
	local key="$1"
	local input="$2"
	bb.preconditions.not_null key || return $?
	bb.preconditions.not_null input || return $?
	bb.preconditions.require_command jq || return $?

	local jpath
	jpath=$(_bb.json.as_jpath "$key")
	jq -r "del($jpath)" <(bb.io.file_or_var "$input")
}

bb.json.inplace.delete() {
  local key=$1
  local input=$2
  bb.preconditions.require_file "$input" || return $?

  output=$(bb.json.delete "$key" "$input")
  local exit_code=$?
  if [ "$exit_code" != 0 ]; then
	 bb.log.error "Failed to delete json key (error $exit_code): $output"
	 return $exit_code
  fi
  echo -e "$output" > "$input"
}

# Merges the json contents of overriding_input with the json of base_input
# USAGE
#   bb.json.merge "BUILD_INFO.json" "new.json"
bb.json.merge() {
  local base_input="$1"
  local overriding_input="$2"
  bb.preconditions.not_null base_input || return $?
  bb.preconditions.not_null overriding_input || return $?
  jq -s '.[0] * .[1]' <(bb.io.file_or_var "$base_input") <(bb.io.file_or_var "$overriding_input")
}

bb.json.inplace.merge() {
	local base_input="$1"
	local overriding_input="$2"
	bb.preconditions.not_null base_input || return $?
	bb.preconditions.not_null overriding_input || return $?
	bb.preconditions.require_file "$base_input" || return $?

	local output
	output=$(bb.json.merge "$base_input" "$overriding_input")
	local exit_code=$?
	if [ "$exit_code" != 0 ]; then
		bb.log.error "Failed to merge json (error $exit_code): $output"
		return "$exit_code"
	fi
	echo -e "$output" > "$base_input"
}

# messy: add trailing quote, add quote after first `.`, surround remaining `.` with quotes
# TL;DR: `.foo.bar` becomes `."foo"."bar"`
_bb.json.as_jpath() {
	local input="$1"
	bb.preconditions.not_null input || return $?
	echo "$input\"" | sed 's/^\./\."/' | sed 's/\./\"\.\"/2g'
}

