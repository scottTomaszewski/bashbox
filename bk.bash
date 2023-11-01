#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <subcommand> [<subcommand> ...] <args...>"
    exit 1
fi

# Extract the subcommands
subcommands=()
args=("$@")

while [[ "$1" != *.* && "$1" != "" ]]; do
    subcommands+=("$1")
    shift
done

if [ "${#subcommands[@]}" -eq 0 ]; then
    echo "No subcommand provided."
    exit 1
fi

# Extract the sub-subcommand
subcommand="${subcommands[0]}"
shift

# Check if the corresponding function exists
if [ -f "commands/${subcommand}.bash" ]; then
    source "commands/${subcommand}.bash"
    if [ "$(type -t "${subcommand}.${1}")" = "function" ]; then
        # Call the specified function with the remaining arguments
        "${subcommand}.${1}" "${@:2}"
    else
        echo "Sub-subcommand not found: $1"
        exit 1
    fi
else
    echo "Subcommand not found: $subcommand"
    exit 1
fi
