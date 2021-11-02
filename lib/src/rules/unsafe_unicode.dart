// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/unicode_utils.dart';

const _desc = r'Do not use bidirectional Unicode text.';

const _details = r'''

**AVOID** using bidirectional Unicode text.

[Bidirectional Unicode](https://unicode.org/reports/tr9/) text may be
interpreted and compiled differently than how it appears in editors
leading to possible security vulnerabilities. 

See the Common Vulnerabilities and Exposures (CVE) publication:
[CVE-2021-42574](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-42574)
for more details.
''';

class UnsafeUnicode extends LintRule {
  UnsafeUnicode()
      : super(
            name: 'unsafe_unicode',
            // todo(pq): consider a message that includes the right escape sequence to use
            description: _desc,
            details: _details,
            // todo(pq): consider a new 'security' group
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  final String source;

  _Visitor(this.rule, LinterContext context)
      : source = context.currentUnit.content;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // todo(pq): consider lower level (byte) scanning
    for (var unit in source.codeUnits) {
      if (unsafe(unit)) {
        // Report at start of file.
        rule.reportLintForOffset(0, 1);
        return;
      }
    }
  }
}
