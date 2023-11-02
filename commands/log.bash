#!/bin/bash

bb.log.info() {
	message="$@"
	echo -e "[INFO] $message" >&2
}

bb.log.warn() {
	bb.log.warning "$@"
}

bb.log.warning() {
	message="$@"
	bb.log.color yellow "[WARNING] $message"
}

bb.log.error() {
	message="$@"
	bb.log.color red "[ERROR] $message"
}

bb.log.title() {
	bb.preconditions.require_command figlet
	figlet >&2 "$@"
}

bb.log.header() {
	bb.preconditions.require_command figlet
	figlet -f small "$@" >&2
}

# Uses echo to print message in desired color. Colors are specified in bb.log.color.code
bb.log.color() {
	local COLOR_STRING=$1
	bb.preconditions.not_null COLOR_STRING || return $?
	local MESSAGE="${@:2}"
	local COLOR_CODE=$(CI::COLOR::code "$COLOR_STRING")
	local TXTRESET="$(tput sgr 0 2> /dev/null || echo '\e[0m')"
	echo -e "${COLOR_CODE}${MESSAGE}${TXTRESET}" >&2
}

bb.log.color.code() {
	local color_string="$1"
	bb.preconditions.not_null color_string || return $?

	# Text colors
	local TXTBLK="$(tput setaf 0 2> /dev/null || echo '\e[0;30m')"
	local TXTRED="$(tput setaf 1 2> /dev/null || echo '\e[0;31m')"
	local TXTGRN="$(tput setaf 2 2> /dev/null || echo '\e[0;32m')"
	local TXTYLW="$(tput setaf 3 2> /dev/null || echo '\e[0;33m')"
	local TXTBLU="$(tput setaf 4 2> /dev/null || echo '\e[0;34m')"
	local TXTPUR="$(tput setaf 5 2> /dev/null || echo '\e[0;35m')"
	local TXTCYN="$(tput setaf 6 2> /dev/null || echo '\e[0;36m')"
	local TXTWHT="$(tput setaf 7 2> /dev/null || echo '\e[0;37m')"

	case "$color_string" in
	black) local COLOR_START="$TXTBLK" ;;
	red) local COLOR_START="$TXTRED" ;;
	green) local COLOR_START="$TXTGRN" ;;
	yellow) local COLOR_START="$TXTYLW" ;;
	blue) local COLOR_START="$TXTBLU" ;;
	magenta) local COLOR_START="$TXTPUR" ;;
	cyan) local COLOR_START="$TXTCYN" ;;
	white) local COLOR_START="$TXTWHT" ;;
	*) local COLOR_START="" ;;
	esac
	echo "$COLOR_START"
}
