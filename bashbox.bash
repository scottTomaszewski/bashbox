#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <subcommand>.<sub-subcommand> <args...>"
    exit 1
fi

# Extract the subcommand and sub-subcommand
IFS='.' read -ra cmd_array <<< "$1"
subcommand="${cmd_array[0]}"
subsubcommand="${cmd_array[1]}"
shift 1


# Check if the corresponding function exists
if [ -f "commands/${subcommand}.bash" ]; then
    source "commands/${subcommand}.bash"
    if [ "$(type -t "${subcommand}.${subsubcommand}")" = "function" ]; then
        # Call the specified function with the remaining arguments
        "${subcommand}.${subsubcommand}" "$@"
    else
        echo "Sub-subcommand not found: $subsubcommand"
        exit 1
    fi
else
    echo "Subcommand not found: $subcommand"
    exit 1
fi
