Utility to number headings and generate Table of contents for Markdown files.

## Table of Contents

1. [Overview](#1)
2. [Usage](#2)
    - 2.1. [Summary](#2.1)
    - 2.2. [Producing output](#2.2)
    - 2.3. [Heading syntax](#2.3)
    - 2.4. [Table of contents](#2.4)
    - 2.5. [Heading levels](#2.5)
        - 2.5.1. [Default processes level 2 headings and higher](#2.5.1)
        - 2.5.2. [Changing the level of processed headings](#2.5.2)
    - 2.6. [Removing the table of contents and numbering](#2.6)
3. [Installation](#3)
    - 3.1. [Dart](#3.1)
        - 3.1.1. [Dependency of a Dart project](#3.1.1)
        - 3.1.2. [Global install](#3.1.2)
        - 3.1.3. [Script runs anywhere Dart is available](#3.1.3)
        - 3.1.4. [Compiled executable runs without needing Dart](#3.1.4)
    - 3.2. [Binary](#3.2)
4. [Limtations](#4)
    - 4.1. [Fenced code blocks may be incorrectly treated as headings](#4.1)

<a class="markdown-toc-generated" id="1"></a>
## 1. Overview

This utility adds heading numbers and a table of contents to a
Markdown file.

It is used to make long Markdown files easier to navigate and read.

For example, it takes a Markdown file containing:

```markdown
|  Document title
|  ==============
|
|  ## Alpha
|
|  ### Foo
|
|  ### Bar
|
|  ## Beta
|
|  ## Gamma
```

And generates:

```markdown
|  Document title
|  ==============
|
|  ## Table of contents
|
|  1. Alpha
|      - 1.1 Foo
|      - 1.2 Bar
|  2. Beta
|  3. Gamma
|
|  ## 1. Alpha
|
|  ### 1.1 Foo
|
|  ### 1.2 Bar
|
|  ## 2. Beta
|
|  ## 3. Gamma
```

_Note: this README has been processed by the utility, to automatically
generate the above Table of Contents and the numbered headings.  The
Markdown in the embedded examples start with extra "|" at the
beginning of the lines, to prevent the utility from recognising their
contents as headings for it to process._

This is a simplified example: the actual output also contains
hyperlinks from the entries in the table of contents to the sections
they refer to.

The utility can also update the numbering and table of contents. It
can be re-run on its own output: which is useful if headings have been
added, changed or removed.

It can also be used to strip out the table of contents and heading
numbers. That is, to revert it back to the original input Markdown.

<a class="markdown-toc-generated" id="2"></a>
## 2. Usage

<a class="markdown-toc-generated" id="2.1"></a>
### 2.1. Summary

```
Usage: markdown_toc [options] {markdown-files}
Options:
-t | --top-level N  lowest numbered heading level (default: 2)
-m | --max-level N  highest numbered heading level (default: 5)

-o | --output FILE  write result to named output file (default: stdout)
-r | --replace      replace input file with the result instead of to output

-s | --strip        remove ToC and numbering, instead of adding/updating them

-v | --verbose      output extra information when running
     --version      display version information and exit
-h | --help         display this help and exit
```

<a class="markdown-toc-generated" id="2.2"></a>
### 2.2. Producing output

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

<a class="markdown-toc-generated" id="2.3"></a>
### 2.3. Heading syntax

The utility only processes headers that use the leading "#" Markdown
syntax.  It ignores headers that use the underline Markdown syntax.

<a class="markdown-toc-generated" id="2.4"></a>
### 2.4. Table of contents

The table of contents is inserted immediately before the first
recognised heading.

<a class="markdown-toc-generated" id="2.5"></a>
### 2.5. Heading levels

<a class="markdown-toc-generated" id="2.5.1"></a>
#### 2.5.1. Default processes level 2 headings and higher

If it processes level 2 headers and higher (the default), this allows
the document's title to be formatted as a level 1 heading using the
underline syntax. It will ignore the title (i.e. not number it and not
include it in the table of contents) and insert the table of contents
immediately before the first non-ignored heading.

And the maximum level is 5. Headings at level 6 and greater
(i.e. those starting with Markdown "######") will not be numbered and
will not appear in the table of contents.

For example,

```markdown
|  Title
|  =====
|
|  ## First
|
|  ### Subsection
|
|  ## Second
|
```

Will produce:

```markdown
|  Title
|  =====
|
|  ## Table of Contents
|
|  ...
|
|  ## 1. First
|
|  ### 1.1. Subsection
|
|  ## 2. Second
```

<a class="markdown-toc-generated" id="2.5.2"></a>
#### 2.5.2. Changing the level of processed headings

The heading levels which are processed is changed using the
`--top-level` and `--max-level` options.

For example, some Markdown files use a metadata block for the document
title and level 1 headings used as normal headings.

```markdown
|  % The document's title
|  % Author
|  % Version 1.0.0
|
|  # First
|
|  ## Subsection
|
|  # Second
```

Use the `--top-level` option to include the level 1 headings:

```shell
$ markdown_toc --top-level 1  example.md
```

Produces:

```markdown
|  % The document's title
|  % Author
|  % Version 1.0.0
|
|  # Table of contents
|
|  ...
|
|  # 1. First
|
|  ## 1.1 Subsection
|
|  # 2. Second
```

<a class="markdown-toc-generated" id="2.6"></a>
### 2.6. Removing the table of contents and numbering

Use the `--strip` option to remove the information added by the utility.

```shell
$ markdown_toc.dart --strip example-with-toc.md
```

<a class="markdown-toc-generated" id="3"></a>
## 3. Installation

`markdow_toc` is not meant to be used as a dependncy. Instead, it
should be installed.

There are a number of ways it can be installed.

<a class="markdown-toc-generated" id="3.1"></a>
### 3.1. Dart

When used to manage Markdown files in a Dart project, this utility can
be made a development dependency of the project.

<a class="markdown-toc-generated" id="3.1.1"></a>
#### 3.1.1. Dependency of a Dart project

This utility is intended to be included in a Dart project development
dependency, so it can be used to add numbered headings and table of
contents to long Markdown documents in the project.

In _pubspec.yaml_ add:

```yaml
dev_dependencies:
  markdown_toc: ^1.1.0
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

<a class="markdown-toc-generated" id="3.1.2"></a>
#### 3.1.2. Global install

Alternatively, install it using "dart pub global activate" so it can
be used on any Markdown files (not just those used to document Dart
projects).

```shell
$ dart pub global activate markdown_toc
```

If the global directory is on the PATH, the utility can be run using:

```shell
$ markdown_toc --help
```

Or it can always be run with:

```shell
dart pub global run markdown_toc --help
```

<a class="markdown-toc-generated" id="3.1.3"></a>
#### 3.1.3. Script runs anywhere Dart is available

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

<a class="markdown-toc-generated" id="3.1.4"></a>
#### 3.1.4. Compiled executable runs without needing Dart

Compile it to a self-contained executable. Which can be run anywhere,
without needing the Dart executable.

```shell
dart compile exe bin/markdown_toc.dart

bin/markdown_toc --help
```

<a class="markdown-toc-generated" id="3.2"></a>
### 3.2. Binary

Binaries can be downloaded from the project's GitHub
[releases](https://github.com/hoylen/markdown_toc/releases/).

Copy the program to a location in your PATH.

<a class="markdown-toc-generated" id="4"></a>
## 4. Limtations

<a class="markdown-toc-generated" id="4.1"></a>
### 4.1. Fenced code blocks may be incorrectly treated as headings

The lines inside fenced code blocks (i.e. lines between lines starting
with ```) are not treated as different. If they contain lines
starting with "#" (with or without whitespace before it), they may be
incorrectly processed as headings.

Since the `--top-level` is usually set to 2 or higher. This problem
only occurs when lines inside the fenced code blocks start with two or
more "#", which may not occur.

A workaround is to modify the lines inside the fenced code blocks. For
example, by adding a prefix to them so they don't start with the "#".
