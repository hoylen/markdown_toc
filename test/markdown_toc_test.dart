import 'dart:io';

import 'package:test/test.dart';

import '../bin/markdown_toc.dart';

//----------------------------------------------------------------

void tests() {
  final testCaseDir = Directory('test/test-cases');
  test('test-cases', () {
    expect(testCaseDir.existsSync(), isTrue,
        reason: 'directory not found: ${testCaseDir.path}');
  });

  // Scan the directory for test case input files

  const inputSuffix = '-input.md';
  const outputSuffix = '-output.md';

  final inputFiles = <File>[];

  for (final item in testCaseDir.listSync()) {
    if (item.path.endsWith(outputSuffix)) {
      // Expected output: ignore
    } else if (item.path.endsWith(inputSuffix)) {
      // Input markdown: use
      if (item is File) {
        inputFiles.add(item);
      } else {
        fail('not a file: ${item.path}');
      }
    } else {
      // ignore file
      print('warning: unexpected file: $item');
    }
  }

  // Use each input file as a test

  for (final inputFile in inputFiles) {
    test(inputFile.path, () {
      // Load the input

      final inputLines = inputFile.readAsLinesSync();

      const topLevel = 2;
      const numLevel = 5;
      const tocLevel = 6;
      const strip = false;

      // Load the expected output

      final expectedFile =
          File(inputFile.path.replaceAll(inputSuffix, outputSuffix));
      expect(expectedFile.existsSync(), isTrue,
          reason: 'missing expected output file: $expectedFile');

      final expectedOutput = expectedFile.readAsStringSync();

      // Test if the processor produces the expected output

      final processor = TocProcessor(
          topLevel: topLevel,
          numLevel: numLevel,
          tocLevel: tocLevel,
          strip: strip);

      processor.parse(inputLines);

      final buf = StringBuffer();
      processor.output(buf);
      expect(buf.toString(), equals(expectedOutput));
    });
  }
}
//----------------------------------------------------------------

void main() {
  tests();
}
