import 'dart:io';

import 'package:test/test.dart';

main() {
  test('validate source formatting', () async {
    try {
      ProcessResult result = await Process
          .run('dartfmt', ['--dry-run', '--set-exit-if-changed', '.']);
      List<String> violations = result.stdout.toString().split('\n')
        ..removeWhere(formattingIgnored);
      expect(violations, isEmpty, reason: '''Some files need formatting. 
  
Run `dartfmt` and (re)commit.''');
    } on ProcessException {
      // This occurs, notably, on appveyor.
      print('[WARNING] format validation skipped -- `dartfmt` not on PATH');
    }
  });
}

bool formattingIgnored(String location) =>
    location.isEmpty ||
    location.startsWith('test/_data/') ||
    location.startsWith('test/rules/');
