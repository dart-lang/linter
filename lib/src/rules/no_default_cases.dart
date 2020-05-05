// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

import '../analyzer.dart';

const _desc = r'No default cases.';

const _details = r'''
Switches on enums and enum-like classes should not use a `default` clause.

Enum-like classes are defined as concrete (non-abstract) classes that have:
  * only private non-factory constructors
  * two or more static const fields whose type is the enclosing class and
  * no subclasses of the class in the defining library

**DO** define default behavior outside switch statements.

**GOOD:**
```
  switch (testEnum) {
    case TestEnum.A:
      return '123';
    case TestEnum.B:
      return 'abc';
  }
  // Default here.
  return null;
```

**BAD:**
```
  switch (testEnum) {
    case TestEnum.A:
      return '123';
    case TestEnum.B:
      return 'abc';
    default:
      return null;
  }
```
''';

class NoDefaultCases extends LintRule implements NodeLintRule {
  NoDefaultCases()
      : super(
            name: 'no_default_cases',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this);
    registry.addSwitchStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitSwitchStatement(SwitchStatement statement) {
    var expressionType = statement.expression.staticType;
    if (expressionType is InterfaceType) {
      // Restrict checks to enums and enum-like classes.
      var classElement = expressionType.element;
      if (!classElement.isEnum) {
        var enumDescription = DartTypeUtilities.asEnumLikeClass(classElement);
        if (enumDescription == null) {
          return;
        }
      }

      for (var member in statement.members) {
        if (member is SwitchDefault) {
          rule.reportLint(member);
        }
      }
    }
  }
}
