#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <subcommand> <args...>"
    exit 1
fi

BASHBOX=$0

# Extract the first argument as the subcommand
subcommand="$1"
shift 1

set -a
for FILE in commands/*.bash; do . $FILE; done
set +a

if [ "$(type -t "bb.${subcommand}")" = "function" ]; then
    # Call the specified function with the remaining arguments
    "bb.${subcommand}" "$@"
else
    echo "Subcommand not found: $subcommand"
    exit 1
fi
