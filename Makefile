# Makefile

all:
	@echo "precommit   - run the utility over the README.md file"

precommit:
	bin/markdown_toc.dart --replace README.md
