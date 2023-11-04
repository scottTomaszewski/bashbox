# TODO - docs

# @description
# ---
# Prints the current datetime in ISO 8601 format
#
# @example
# # prints `2023-11-04T15:25:48-04:00`
# bb datetime.now.iso
#
# @exitcode 0 if successful
bb.datetime.now.iso() {
	date +"%Y-%m-%dT%H:%M:%S%:z"
}

# @description
# ---
# Prints the current datetime in human-readable format
#
# @example
# # prints `Sat 04 Nov 2023 03:26:23 PM EDT`
# bb datetime.now.hr
#
# @exitcode 0 if successful
bb.datetime.now.hr() {
	date
}

# @description
# ---
# Prints the current datetime in second-since-epoch (unix time) format
#
# @example
# # prints `1699126036`
# bb datetime.now.unix
#
# @exitcode 0 if successful
bb.datetime.now.unix() {
	bb.datetime.now.unix_seconds
}

# @description
# ---
# Prints the current datetime in second-since-epoch (unix time) format
#
# @example
# # prints `1699126036`
# bb datetime.now.unix_seconds
#
# @exitcode 0 if successful
bb.datetime.now.unix_seconds() {
	date +%s
}

# @description
# ---
# Prints the current datetime in millisecond-since-epoch format
#
# @example
# # prints `1699126068601`
# bb datetime.now.unix_milli
#
# @exitcode 0 if successful
bb.datetime.now.unix_milli() {
	date +%s%3N
}

# @description
# ---
# Prints the current datetime in nanosecond-since-epoch format
#
# @example
# # prints `1699126120375297871`
# bb datetime.now.unix_nano
#
# @exitcode 0 if successful
bb.datetime.now.unix_nano() {
	date +%s%N
}
