#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <subcommand> <args...>"
    exit 1
fi

BASHBOX=$0

if [ "$1" == "home_dir" ]; then
	# Check BASHBOX_HOME for commands
	if [ -n "$BASHBOX_HOME" ]; then 
        	if [ -f "$BASHBOX_HOME/commands/preconditions.bash" ]; then
               	src_dir="$BASHBOX_HOME"
	        else
        	        echo "BASHBOX_HOME has value $BASHBOX_HOME but cannot find commands."
                	exit 1
	        fi

	# Check standard install location for commands
	elif [ -f "/usr/local/lib/bashbox/commands/preconditions.bash" ]; then
        	src_dir="/usr/local/lib/bashbox"

	# Check relative path for commands
	else
        	# this is a copy of bb.io.full_dir_of.  I havent sourced it yet, so I dont have it available...
	        source=${BASH_SOURCE[0]}
        	while [ -L "$source" ]; do # resolve $source until the file is no longer a symlink
                	src_dir=$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )
	                source=$(readlink "$source")
        	       [[ $source != /* ]] && source=$src_dir/$source # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
        	done
	        src_dir=$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )

		if [ ! -f "${src_dir}/commands/preconditions.bash" ]; then
	                echo "Could not find bashbox commands. Exiting"
	                exit 1
	        fi
	fi
	echo "$src_dir"
	exit 0
fi

src_dir=$($BASHBOX home_dir)

# Extract the first argument as the subcommand
subcommand="$1"
shift 1

set -a
for FILE in "$src_dir"/commands/*.bash; do . $FILE; done
set +a

if [ "$(type -t "bb.${subcommand}")" = "function" ]; then
    # Call the specified function with the remaining arguments
    "bb.${subcommand}" "$@"
else
    echo "Subcommand not found: $subcommand"
    exit 1
fi
