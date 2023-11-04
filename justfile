# List commands
default:
    @just --list --unsorted

# Generates markdown docs for bashbox
gen_docs: update_readme
	./bashbox.bash docs.generate_for_bash commands docs

update_readme:
	#!/usr/bin/env bash
	set -eo pipefail
	echo "# Bashbox" > README.md
	echo "" >> README.md
	echo " ## Command Docs" >> README.md
	echo "" >> README.md
	./bashbox.bash docs.markdown_links >> README.md

install_completions:
	cp bb_completion /etc/bash_completion.d/
