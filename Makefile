# Makefile

.PHONY: example

all:
	@echo "Targets:"
	@echo "  precommit  run before commit"
	@echo
	@echo "  format     dart format"
	@echo "  readme     run the utility to update the README.md"
	@echo "  example    run the utility to produce the example/example.md"
	@echo
	@echo "  pana       run pana"
	@echo

#----------------------------------------------------------------

precommit: format readme example

#----------------------------------------------------------------

readme:
	bin/markdown_toc.dart --replace README.md

format:
	dart format bin test

example:
	bin/markdown_toc.dart example/input.md --output example/example.md

#----------------------------------------------------------------

pana:
	dart run pana:pana --no-warning
