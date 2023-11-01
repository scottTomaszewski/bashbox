#!/bin/bash

# log.bash

log.warn() {
    message="$1"
    echo "Log Warning: $message $color_string"
}

log.info() {
    message="$1"
    echo "Log Info: $message"
}

log.fatal() {
    message="$1"
    echo "Log Fatal: $message"
}

log.foo.bar() {
    message="$1"
    echo "Foo bar: $message"
}

log.color.code() {
  local color_string="$1"
  $BASHBOX log.warn "what is happening?"
  preconditions.not_null color_string || return $?

  # Text colors
  local TXTBLK="$(tput setaf 0 2>/dev/null || echo '\e[0;30m')"
  local TXTRED="$(tput setaf 1 2>/dev/null || echo '\e[0;31m')"
  local TXTGRN="$(tput setaf 2 2>/dev/null || echo '\e[0;32m')"
  local TXTYLW="$(tput setaf 3 2>/dev/null || echo '\e[0;33m')"
  local TXTBLU="$(tput setaf 4 2>/dev/null || echo '\e[0;34m')"
  local TXTPUR="$(tput setaf 5 2>/dev/null || echo '\e[0;35m')"
  local TXTCYN="$(tput setaf 6 2>/dev/null || echo '\e[0;36m')"
  local TXTWHT="$(tput setaf 7 2>/dev/null || echo '\e[0;37m')"

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
