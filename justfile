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
	@cp bb_completion /etc/bash_completion.d/
	@echo "Bashbox autocompletion prepared.  Please add the following to ~/.bashrc or equivalent:"
	@echo ""
	@echo "source /etc/bash_completion.d/bb_completion"

install: uninstall && install_completions
	#!/usr/bin/env bash
	set -eo pipefail
	# TODO - make this a symlink
	cp bashbox.bash /usr/local/bin/bb
	mkdir -p /usr/local/lib/bashbox
	cp -R commands /usr/local/lib/bashbox/commands	

uninstall:
	#!/usr/bin/env bash
	set -eo pipefail
	rm -f /usr/local/bin/bb
	rm -rf /usr/local/lib/bashbox
	rm -rf /etc/bash_completion.d/bb_completion
