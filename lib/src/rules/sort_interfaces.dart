// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Sort constructor declarations before other members.';

const _details = r'''
Sort interfaces alphabetically.

**BAD:**
```dart
class I1 {}
class I2 {}
class A implements I2, I1 {}
```

**GOOD:**
```dart
class I1 {}
class I2 {}
class A implements I1, I2 {}
```

''';

class SortInterfaces extends LintRule {
  static const LintCode code = LintCode(
    'sort_interfaces',
    'Sort interfaces alphabetically.',
    correctionMessage: 'Try sorting interfaces alphabetically.',
  );

  SortInterfaces()
      : super(
            name: code.name,
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addImplementsClause(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitImplementsClause(ImplementsClause node) {
    String? lastName;
    for (var namedType in node.interfaces) {
      var name = namedType.name2.lexeme;
      if (lastName != null && lastName.compareTo(name) > 0) {
        rule.reportLintForToken(namedType.name2);
        return;
      }
      lastName = name;
    }
  }
}
