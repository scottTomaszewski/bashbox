#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <subcommand> <args...>"
    exit 1
fi

BASHBOX=$0

# Extract the subcommand filename
subcommand_filename=$(echo "$1" | awk -F. '{print $1}')

# Extract the first argument as the subcommand
subcommand="$1"
shift 1

set -a
for FILE in commands/*.bash; do source $FILE; echo "sourced $FILE"; done
set +a

# Check if the corresponding function exists
command_file="commands/${subcommand_filename}.bash"

if [ -f "$command_file" ]; then
    source "$command_file"
    if [ "$(type -t "${subcommand}")" = "function" ]; then
        # Call the specified function with the remaining arguments
        "${subcommand}" "$@"
    else
        echo "Subcommand not found: $subcommand"
        exit 1
    fi
else
    echo "Subcommand not found: $subcommand"
    exit 1
fi
