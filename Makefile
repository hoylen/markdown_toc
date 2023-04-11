# Makefile

.PHONY: example

all:
	@echo "precommit  run the utility over the README.md file"
	@echo "pana       run pana"

precommit:
	bin/markdown_toc.dart --replace README.md

example:
	bin/markdown_toc.dart example/example.md --output example/output.md

pana:
	dart run pana:pana --no-warning
