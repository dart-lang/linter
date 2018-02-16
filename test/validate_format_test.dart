import 'dart:io';

import 'package:test/test.dart';

main() {
  test('validate source formatting', () async {
    ProcessResult result = await Process
        .run('dartfmt', ['--dry-run', '--set-exit-if-changed', '.']);
    List<String> violations = result.stdout.toString().split('\n')
      ..removeWhere(formattingIgnored);
    expect(violations, isEmpty, reason: '''Some files need formatting. 
  
Run `dartfmt` and (re)commit.''');
  });
}

bool formattingIgnored(String location) =>
    location.isEmpty ||
    location.startsWith('test/_data/') ||
    location.startsWith('test/rules/');
