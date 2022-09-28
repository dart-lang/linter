// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r"Don't use adjacent strings in list.";

const _details = r'''
**DON'T** use adjacent strings in list.

This can be sign of forgotten comma.

**GOOD:**
```dart
List<String> list = <String>[
  'a' +
  'b',
  'c',
];
```

**BAD:**
```dart
List<String> list = <String>[
  'a'
  'b',
  'c',
];
```

''';

class NoAdjacentStringsInList extends LintRule {
  NoAdjacentStringsInList()
      : super(
            name: 'no_adjacent_strings_in_list',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addListLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitListLiteral(ListLiteral node) {
    for (var e in node.elements) {
      if (e is AdjacentStrings) {
        rule.reportLint(e);
      }
    }
  }
}
