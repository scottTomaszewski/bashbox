# List commands
default:
    @just --list --unsorted

# Generates markdown docs for bashbox
gen_docs:
	./bashbox.bash docs.generate_for_bash commands docs
