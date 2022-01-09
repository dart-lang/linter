// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Avoid declaring variables with var.';

const _details = r'''

**DO** declare a variable using its explicit type if it is reassigned, or final,
if it is not.

Declaring a variable using its explicit type is slightly more verbose but
improves readability, adds self-documentation and makes sure that you are not
dependant on compiler-inferred types. Declaring variables as final is good
practice because it helps avoiding accidental reassignments and allows the
compiler to do optimization.

**BAD:**
```dart
class Person {
  var name = 'Bella';
  var age = 64;
  var ageAtBirth = 0;

  void celebratesBirthday() => age++;
  void addsSecondName(String secondName) => name = '$name $secondName';
}
```

**GOOD:**
```dart
class Person {
  String name = 'Bella';
  int age = 64;
  static const ageAtBirth = 0;

  void celebratesBirthday() => age++;
  void addsSecondName(String secondName) => name = '$name $secondName';
}
```

**BAD:**
```dart
double foo() {
  var x = 20;
  x += 3;
  var y = x / 3;
  return y;
}
```

**GOOD:**
```dart
double foo() {
  int x = 20;
  x += 3;
  final y = x / 3;
  return y;
}
```

**BAD:**
```dart
for (var x in [1, 2, 3]) {
  print(x);
}
```

**GOOD:**
```dart
for (int x in [1, 2, 3]) {
  x = x + x;
  print(x);
}
```

**GOOD:**
```dart
for (final x in [1, 2, 3]) {
  print(x);
}
```
''';

class AvoidVarDeclarations extends LintRule {
  AvoidVarDeclarations()
      : super(
            name: 'avoid_var_declarations',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  List<String> get incompatibleRules =>
      const ['unnecessary_final', 'omit_local_variable_types'];

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry
      ..addVariableDeclarationList(this, visitor)
      ..addDeclaredIdentifier(this, visitor)
      ..addSimpleFormalParameter(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    if (!node.isConst &&
        !node.isFinal &&
        node.keyword != null &&
        node.type == null) {
      rule.reportLintForToken(node.keyword);
    }
  }

  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    if (!node.isConst &&
        !node.isFinal &&
        node.keyword != null &&
        node.type == null) {
      rule.reportLintForToken(node.keyword);
    }
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter param) {
    if (!param.isConst &&
        !param.isFinal &&
        param.keyword != null &&
        param.type == null) {
      rule.reportLintForToken(param.keyword);
    }
  }
}
