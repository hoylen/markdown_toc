#!/usr/bin/env dart
//
// Markdown table of contents utility.
//
// Adds a table of contents and numbers the headings in a Markdown file.
//
// **Format**
//
// The Markdown MUST represent headings included in the table of contents
// using the leading has (#) syntax.
//
// Headings not included in the table of contents SHOULD be represented using
// the underline syntax. The table of contents is inserted immediately before
// the first heading formatted using "#" (even if it is at a higher level
// than the top level).
//
// Headings at levels higher than the top level for the table of contents
// MUST be represented using the underline syntax.
//
// For example, if using a level 1 heading as the title of the document, use
// double underline (i.e. equal signs) to format it. And all other headings
// should use the "#" format.
//
//----------------------------------------------------------------

import 'dart:io';

//----------------------------------------------------------------

const program = 'markdown_toc';
const version = '1.0.0';

//----------------------------------------------------------------

const defaultTopLevel = 2;

//################################################################
/// Options from the command line.

class Options {
  //================================================================
  // Constructors

  //----------------------------------------------------------------
  /// Parse command line arguments.

  factory Options(String exeName, List<String> arguments) {
    final filenames = <String>[];
    var strip = false;
    var topLevel = defaultTopLevel;
    var verbose = false;
    var outputReplace = false;
    String? outputFile;

    // Doing our own command line parsing to avoid the need for external
    // packages, so this program can be run without needing a pubspec.yaml file.

    var index = 0;
    while (index < arguments.length) {
      final arg = arguments[index++];

      switch (arg) {
        case '-r':
        case '--replace':
          outputReplace = true;
          break;

        case '-o':
        case '--output':
          outputFile = arguments[index++];
          break;

        case '-s':
        case '--strip':
          strip = true;
          break;

        case '-t':
        case '--top-level':
          try {
            final str = arguments[index++];
            try {
              topLevel = int.parse(str);
              if (topLevel <= 0) {
                _usageError(exeName,
                    'top-level: level must be greater than zero: $topLevel');
              } else if (10 < topLevel) {
                _usageError(exeName, 'top-level: level too large: $topLevel');
              }
            } on FormatException {
              _usageError(exeName, 'top-level: not an integer: $str');
            }
          } on RangeError {
            _usageError(exeName, 'top-level: missing argument');
          }
          break;

        case '-v':
        case '--verbose':
          verbose = true;
          break;

        case '--version':
          stdout.writeln('$program $version');
          exit(0);

        case '-h':
        case '--help':
          stdout.write('''
Usage: $exeName [options] markdown-file
Options:
-s | --strip        remove ToC and numbering, instead of adding/updating them
-t | --top-level N  heading level at top level (default: $defaultTopLevel)

-o | --output FILE  write result to named output file (default: stdout)
-r | --replace      replace input file with the result instead of to output

-v | --verbose      output extra information when running    
     --version      display version information and exit
-h | --help         display this help and exit
''');
          exit(0);

        default:
          if (arg.startsWith('-')) {
            _usageError(exeName, 'unknown option: $arg');
          } else {
            filenames.add(arg);
          }
          break;
      }
    }

    if (outputReplace && outputFile != null) {
      _usageError(exeName, 'cannot specify both --replace and --output');
    }

    if (filenames.isEmpty) {
      _usageError(exeName, 'missing markdown file (-h for help)');
    } else if (1 < filenames.length) {
      if (!outputReplace) {
        _usageError(exeName,
            'multiple input files can only be processed if --replace is used');
      }
    }

    return Options._init(filenames, topLevel,
        strip: strip,
        verbose: verbose,
        outputReplace: outputReplace,
        outputFile: outputFile);
  }

  //----------------------------------------------------------------
  /// Internal constructor.

  Options._init(this.filenames, this.topLevel,
      {this.strip = false,
      this.verbose = false,
      this.outputReplace = false,
      this.outputFile});

  //================================================================

  List<String> filenames;

  bool strip;
  int topLevel;
  bool verbose;

  bool outputReplace;
  String? outputFile;

  //================================================================

  static Never _usageError(String exeName, String message) {
    stderr.writeln('$exeName: usage error: $message');
    exit(2);
  }
}
//################################################################

class TocEntry {
  TocEntry(this.level, this.number, this.text);

  int level;
  String number;
  String text;
}

//################################################################

enum Position { beforeToc, inToc, afterToc }

//################################################################

class TocProcessor {
  //================================================================
  // Constructors

  TocProcessor({this.topLevel = 1, this.strip = false});

  //================================================================
  // Constants

  static const _tocHeadingText = 'Table of Contents';

  static const _tocAnchorTagStart = '<a class="markdown-toc-generated" id';

  // Could define as "section" so IDs are like "section_3.2.1".
  // But this is not necessary, since "3.2.1" is a valid ID.

  static const _tocAnchorPrefix = '';

  //================================================================
  // Members

  final int topLevel;
  final bool strip;

  final beforeToc = <String>[];
  final tocEntries = <TocEntry>[];
  final afterToc = <String>[];

  //================================================================
  // Methods

  //----------------------------------------------------------------

  void parse(Iterable<String> lines) {
    var position = Position.beforeToc;

    var previousLevel = topLevel;
    final numbers = <int>[0];

    for (final l in lines) {
      var line = l;
      bool normalLine;

      final match = RegExp(r'^ *(#+)[ \t]*[\d.]*[ \t]*(.*)$').firstMatch(line);
      if (match != null) {
        // Heading line

        normalLine = false; // unless discovered later to be higher level

        final hashes = match.group(1)!;
        final text = match.group(2)!.trim();

        bool saveHeading;
        bool outputHeading;

        switch (position) {
          case Position.beforeToc:
            // First heading encountered
            if (text == _tocHeadingText) {
              position = Position.inToc;
              outputHeading = false;
              saveHeading = false;
            } else {
              position = Position.afterToc;
              outputHeading = true;
              saveHeading = true;
            }
            break;
          case Position.inToc:
            // First heading after ToC signals end of the ToC
            position = Position.afterToc;
            outputHeading = true;
            saveHeading = true;
            break;
          case Position.afterToc:
            outputHeading = true;
            saveHeading = true;
            break;
        }

        if (outputHeading) {
          assert(position == Position.afterToc);
          final currentLevel = hashes.length;

          if (topLevel <= currentLevel) {
            // Process heading

            if (previousLevel == currentLevel) {
              // Heading at the same level as the previous heading
              numbers.add(numbers.removeLast() + 1); // increment last number
            } else {
              final diff = currentLevel - previousLevel;
              if (0 < diff) {
                // Section that is nested more deeper
                numbers.addAll(List<int>.filled(diff, 1));
              } else {
                // End of section: back to a higher level
                numbers.removeRange(numbers.length + diff, numbers.length);
                numbers.add(numbers.removeLast() + 1); // increment higher level
              }
              previousLevel += diff;
            }

            if (!strip) {
              // Header with numbers and anchor tag
              afterToc.add(
                  '$_tocAnchorTagStart="${_anchor(numbers.join('.'))}"></a>');
              afterToc.add('$hashes ${numbers.join('.')}. $text');
            } else {
              // Header without numbers
              afterToc.add('$hashes $text');
            }
          } else {
            // Heading is higher than the topLevel: treat as non-heading
            // without any numbers.
            line = '$hashes $text';
            normalLine = true;
          }
        }

        if (saveHeading) {
          tocEntries.add(TocEntry(hashes.length, numbers.join('.'), text));
        }
      } else if (line.startsWith('$_tocAnchorTagStart="$_tocAnchorPrefix')) {
        // Do not include previously generated table of content anchor tags
        normalLine = false;
      } else {
        normalLine = true;
      }

      if (normalLine) {
        // Non-heading line

        switch (position) {
          case Position.beforeToc:
            beforeToc.add(line);
            break;
          case Position.inToc:
            // discard old ToC text
            break;
          case Position.afterToc:
            afterToc.add(line);
            break;
        }
      }
    }
  }

  //----------------------------------------------------------------

  void check(String filename) {
    // Check there is at least one heading at the top level

    if (!tocEntries.any((element) => element.number == '1')) {
      stderr.writeln(
          '$filename: warning: no heading using "#" syntax at level $topLevel');
    }
  }

  //----------------------------------------------------------------

  void output(StringSink dest) {
    // Lines before table of contents

    for (final line in beforeToc) {
      dest.writeln(line);
    }

    if (!strip) {
      // Table of contents
      dest.writeln('## $_tocHeadingText\n');

      for (final entry in tocEntries) {
        if (topLevel <= entry.level) {
          String prefix;
          if (entry.level == topLevel) {
            prefix = entry.number; // this will be a Markdown numbered list
          } else {
            prefix = '${'    ' * (entry.level - topLevel)}- ${entry.number}';
          }
          dest.writeln(
              '$prefix. [${entry.text.trim()}](#${_anchor(entry.number)})');
        }
      }
      dest.writeln();
    }

    // Lines after table of contents'

    for (final line in afterToc) {
      dest.writeln(line);
    }
  }

  //================================================================
  // Static methods

  //----------------------------------------------------------------
  /// Generate the identifier used for the anchor <a> tag.

  static String _anchor(String numbers) => '$_tocAnchorPrefix$numbers';
// '$_tocAnchorPrefix${numbers.replaceAll('.', '_')}';
}

//################################################################

Future<void> processFile(String exeName, String filename,
    {int topLevel = defaultTopLevel,
    bool strip = false,
    bool verbose = false,
    bool outputReplace = false,
    String? outputFile}) async {
  assert(!(outputReplace && outputFile != null),
      'cannot replace input file if an output file was specified');

  final processor = TocProcessor(topLevel: topLevel, strip: strip);

  final sourceFile = File(filename);
  processor.parse(sourceFile.readAsLinesSync());
  processor.check(filename);

  if (verbose) {
    stderr.writeln('$exeName: $filename');
  }

  if (outputReplace) {
    // Replace input file with the result

    final newFile = File('$filename.tmp');
    final backupFile = File('$filename.old');

    // Make sure temporary files do not exist

    if (newFile.existsSync()) {
      stderr.writeln(
          '$exeName: error: temporary file already exists: ${newFile.path}');
      exit(1);
    }
    if (backupFile.existsSync()) {
      stderr.writeln(
          '$exeName: error: backup file already exists: ${backupFile.path}');
      exit(1);
    }

    // Write output to new file

    final sink = newFile.openWrite();
    processor.output(sink);
    await sink.close();

    // Safely replace the original file with the new file

    await sourceFile.rename(backupFile.path); // move original to safe keeping
    await newFile.rename(filename); // move new contents to original filename
    await backupFile.delete(); // delete original

  } else {
    // Print output to specified filename or stdout

    final out = (outputFile != null) ? File(outputFile).openWrite() : null;

    processor.output(out ?? stdout);

    await out?.close();
  }
}

//----------------------------------------------------------------

Future<void> main(List<String> arguments) async {
  final exeName = Platform.script.pathSegments.last.replaceAll('.dart', '');
  final options = Options(exeName, arguments);

  try {
    for (final filename in options.filenames) {
      await processFile(exeName, filename,
          topLevel: options.topLevel,
          strip: options.strip,
          verbose: options.verbose,
          outputReplace: options.outputReplace,
          outputFile: options.outputFile);
    }
  } on FileSystemException catch (e) {
    stderr.write('$exeName: error: ${e.message}: ${e.path}');
    exit(1);
  } catch (e) {
    stderr.write('$exeName: unexpected error (${e.runtimeType}): $e');
    exit(3);
  }
}
