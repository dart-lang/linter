// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/analyzer.dart';
import 'package:linter/src/utils.dart';

const _desc = r'Use brief package descriptions.';

const _details = r'''

**DO** keep package descriptions between 60 and 180 characters long.

Search engines display only the first part of the description. Try to keep the
value of the `description` field in your package's `pubspec.yaml` file between
60 and 180 characters.
''';

class PubPackageDescriptions extends LintRule {
  PubPackageDescriptions()
      : super(
            name: 'package_descriptions',
            description: _desc,
            details: _details,
            group: Group.pub);

  @override
  PubspecVisitor getPubspecVisitor() => new Visitor(this);
}

class Visitor extends PubspecVisitor {
  final LintRule rule;

  Visitor(this.rule);

  @override
  visitPackageDescription(PSEntry description) {
    final length = description.value.text.length;
    if (length < 60 || length > 180) {
      rule.reportPubLint(description.value);
    }
  }
}
