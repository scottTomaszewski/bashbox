# Checks if the `VAR_NAME` is null (as defined by bash conditional for `-z` and `-n`) and returns if not null.
# If `VAR_NAME` is null: print `ERROR_MSG` if provided, otherwise print a default error message.
#
# Usage:
# 	CI::PRECONDITIONS::not_null SOME_VARIABLE "You must set 'SOME_VARIABLE'"
#		=>  You must set 'SOME_VARIABLE'
preconditions.not_null() {
  local VAR_NAME="$1"
  echo "var name $VAR_NAME with value ${!VAR_NAME}"
  local ERROR_MSG="$2"
  if [ -z "$ERROR_MSG" ]; then ERROR_MSG="Expected [$VAR_NAME] to have value, but was empty."; fi
  if [ -n "${!VAR_NAME}" ]; then return; fi

  CI::LOG::error "Precondition failure: $ERROR_MSG"
  return 1
}
