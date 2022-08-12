Adds a table of contents and numbered headings to a Markdown file.

## Overview

This utility adds heading numbers and a table of contents to a
Markdown file.

For example, it takes a Markdown file containing:

```markdown
Document title
==============

## Alpha

### Foo

### Bar

## Beta

## Gamma
```

And generates:

```markdown
Document title
==============

## Table of contents

1. Alpha
    - 1.1 Foo
    - 1.2 Bar
2. Beta
3. Gamma

## 1. Alpha

### 1.1 Foo

### 1.2 Bar

## 2. Beta

## 3. Gamma
```

This is a simplified example: the actual output also contains
hyperlinks from the entries in the table of contents to the sections
they refer to.

The utility can also update the numbering and table of contents. It
can be re-run on its own output: which is useful if headings have been
added, changed or removed.

It can also be used to strip out the table of contents and heading
numbers. That is, to revert it back to the original input Markdown.

## Usage

### Producing output

By default, the results are written to stdout:

```shell
$ markdown_toc.dart example.md
```

But the utility is usually invoked to replace the input file with the
results:

```shell
$ markdown_toc.dart --replace example.md
```

Alternatively, a different output file can be specified:

```shell
$ markdown_toc.dart --output example-with-toc.md example.md
```

### Heading syntax

The utility only processes headers that use the leading "#" Markdown
syntax.  It ignores headers that use the underline Markdown syntax.

### Table of contents

The table of contents is inserted immediately before the first
recognised heading.

### Default processes level 2 headings and higher

If it processes level 2 headers and higher (the default), this allows
the document's title to be formatted as a level 1 heading using the
underline syntax. It will ignore the title (i.e. not number it and not
include it in the table of contents) and insert the table of contents
immediately before the first non-ignored heading.

For example,

```markdown
Title
=====

## First

### Subsection

## Second

```

Will produce:

```markdown
Title
=====

## Table of Contents

...

## 1. First

### 1.1. Subsection

## 2. Second
```

### Changing the level of processed headings

The heading levels which are processed is changed using the
`--top-level` option.

For example, some Markdown files use a metadata block for the document
title and level 1 headings used as normal headings.

```markdown
% The document's title
% Author
% Version 1.0.0

# First

## Subsection

# Second
```

Use the `--top-level` option to include the level 1 headings:

```shell
$ markdown_toc --top-level 1  example.md
```

Produces:

```markdown
% The document's title
% Author
% Version 1.0.0

# Table of contents

...

# 1. First

## 1.1 Subsection

# 2. Second
```

### Removing the table of contents and numbering

Use the `--strip` option to remove the information added by the utility.

```shell
$ markdow_toc.dart --strip example-with-toc.md
```

## Installation

### Dependency of a Dart project

This utility is intended to be included in a Dart project development
dependency, so it can be used to add numbered headings and table of
contents to long Markdown documents in the project.

In _pubspec.yaml_ add:

```yaml
dev_dependencies:
  markdown_toc: ^1.0.0
```

Then run:

```shell
$ dart pub get
```

The utility should be run using the "dart run" command, to run the
specific version of the utility that was installed by "dart pub get".

```shell
$ dart run markdown_toc --help
```

### Global install

Alternatively, install it using "dart pub global activate" so it can
be used on any Markdown files (not just those used to document Dart
projects).

```shell
$ dart pub global activate markdown_toc
```

If the global directory is on the PATH, the utility can be run using:

```shell
$ markdow_toc --help
```

Or it can always be run with:

```shell
dart pub global run markdown_toc --help
```

### Script runs anywhere Dart is available

Finally, the utility has been written to not use any pub packages. So
it can be run anywhere; as long as the _dart_ executable is
available. There is no need for it to be inside a Dart project, nor to
have an associated _pubspec.yaml_ file.

Copy the _markdown_toc.dart_ file to somewhere on the PATH:

```shell
$ cp markdown_toc.dart /usr/local/bin/markdown_toc
```

And then run it as a normal command:

```shell
$ markdown_toc --help
```

### Compiled executable runs without needing Dart

Compile it to a self-contained executable. Which can be run anywhere,
without needing the Dart executable.

```shell
dart compile exe bin/markdown_toc.dart

bin/markdow_toc --help
```
