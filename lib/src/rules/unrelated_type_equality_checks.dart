// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';

const _desc =
    r'Equality operator `==` invocation with references of unrelated types.';

const _details = r'''

**DON'T** Compare references of unrelated types for equality.

Comparing references of a type where neither is a subtype of the other most
likely will return `false` and might not reflect programmer's intent.

`Int64` and `Int32` from `package:fixnum` allow comparing to `int` provided
the `int` is on the right hand side. The lint allows this as a special case. 

**BAD:**
```dart
void someFunction() {
  var x = '1';
  if (x == 1) print('someFunction'); // LINT
}
```

**BAD:**
```dart
void someFunction1() {
  String x = '1';
  if (x == 1) print('someFunction1'); // LINT
}
```

**BAD:**
```dart
void someFunction13(DerivedClass2 instance) {
  var other = DerivedClass3();

  if (other == instance) print('someFunction13'); // LINT
}

class ClassBase {}

class DerivedClass1 extends ClassBase {}

abstract class Mixin {}

class DerivedClass2 extends ClassBase with Mixin {}

class DerivedClass3 extends ClassBase implements Mixin {}
```

**GOOD:**
```dart
void someFunction2() {
  var x = '1';
  var y = '2';
  if (x == y) print(someFunction2); // OK
}
```

**GOOD:**
```dart
void someFunction3() {
  for (var i = 0; i < 10; i++) {
    if (i == 0) print(someFunction3); // OK
  }
}
```

**GOOD:**
```dart
void someFunction4() {
  var x = '1';
  if (x == null) print(someFunction4); // OK
}
```

**GOOD:**
```dart
void someFunction7() {
  List someList;

  if (someList.length == 0) print('someFunction7'); // OK
}
```

**GOOD:**
```dart
void someFunction8(ClassBase instance) {
  DerivedClass1 other;

  if (other == instance) print('someFunction8'); // OK
}
```

**GOOD:**
```dart
void someFunction10(unknown) {
  var what = unknown - 1;
  for (var index = 0; index < unknown; index++) {
    if (what == index) print('someFunction10'); // OK
  }
}
```

**GOOD:**
```dart
void someFunction11(Mixin instance) {
  var other = DerivedClass2();

  if (other == instance) print('someFunction11'); // OK
  if (other != instance) print('!someFunction11'); // OK
}

class ClassBase {}

abstract class Mixin {}

class DerivedClass2 extends ClassBase with Mixin {}
```

''';

bool _hasNonComparableOperands(TypeSystem typeSystem, BinaryExpression node) {
  var left = node.leftOperand;
  var leftType = left.staticType;
  var right = node.rightOperand;
  var rightType = right.staticType;
  if (leftType == null || rightType == null) {
    return false;
  }
  return !DartTypeUtilities.isNullLiteral(left) &&
      !DartTypeUtilities.isNullLiteral(right) &&
      DartTypeUtilities.unrelatedTypes(typeSystem, leftType, rightType) &&
      !(_isFixNumIntX(leftType) && _isCoreInt(rightType));
}

bool _isCoreInt(DartType type) => type.isDartCoreInt;

bool _isFixNumIntX(DartType type) {
  if (type is! InterfaceType) {
    return false;
  }
  Element element = type.element;
  return (element.name == 'Int32' || element.name == 'Int64') &&
      element.library?.name == 'fixnum';
}

class UnrelatedTypeEqualityChecks extends LintRule {
  static const LintCode code = LintCode('unrelated_type_equality_checks',
      "Neither type of the operands of '==' is a subtype of the other.",
      correctionMessage: 'Try changing one or both of the operands.');

  UnrelatedTypeEqualityChecks()
      : super(
            name: 'unrelated_type_equality_checks',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context.typeSystem);
    registry.addBinaryExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;
  final TypeSystem typeSystem;

  _Visitor(this.rule, this.typeSystem);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    var isDartCoreBoolean = node.staticType?.isDartCoreBool ?? false;
    if (!isDartCoreBoolean ||
        (node.operator.type != TokenType.EQ_EQ &&
            node.operator.type != TokenType.BANG_EQ)) {
      return;
    }

    if (_hasNonComparableOperands(typeSystem, node)) {
      rule.reportLint(node);
    }
  }
}
