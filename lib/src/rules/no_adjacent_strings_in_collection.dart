// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r"Don't use adjacent strings in collections.";

const _details = r'''
**DON'T** use adjacent strings in collections.

This can indicate a forgotten comma.

**BAD:**
```dart
List<String> list = <String>[
  'a'
  'b',
  'c',
];
```

**GOOD:**
```dart
List<String> list = <String>[
  'a' +
  'b',
  'c',
];
```
''';

class NoAdjacentStringsInCollection extends LintRule {
  NoAdjacentStringsInCollection()
      : super(
            name: 'no_adjacent_strings_in_collection',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addForElement(this, visitor);
    registry.addIfElement(this, visitor);
    registry.addListLiteral(this, visitor);
    registry.addSetOrMapLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitForElement(ForElement node) {
    if (node.body is AdjacentStrings) {
      rule.reportLint(node.body);
    }
  }

  @override
  void visitIfElement(IfElement node) {
    if (node.thenElement is AdjacentStrings) {
      rule.reportLint(node.thenElement);
    }
  }

  @override
  void visitListLiteral(ListLiteral node) {
    for (var e in node.elements) {
      if (e is AdjacentStrings) {
        rule.reportLint(e);
      }
    }
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    if (node.isMap) return;
    for (var e in node.elements) {
      if (e is AdjacentStrings) {
        rule.reportLint(e);
      }
    }
  }
}
