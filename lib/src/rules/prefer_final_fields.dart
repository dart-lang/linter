// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';

const _desc = r'Private field could be final.';

const _details = r'''

**DO** prefer declaring private fields as final if they are not reassigned later
in the library.

Declaring fields as final when possible is a good practice because it helps
avoid accidental reassignments and allows the compiler to do optimizations.

**BAD:**
```dart
class BadImmutable {
  var _label = 'hola mundo! BadImmutable'; // LINT
  var label = 'hola mundo! BadImmutable'; // OK
}
```

**BAD:**
```dart
class MultipleMutable {
  var _label = 'hola mundo! GoodMutable', _offender = 'mumble mumble!'; // LINT
  var _someOther; // LINT

  MultipleMutable() : _someOther = 5;

  MultipleMutable(this._someOther);

  void changeLabel() {
    _label= 'hello world! GoodMutable';
  }
}
```

**GOOD:**
```dart
class GoodImmutable {
  final label = 'hola mundo! BadImmutable', bla = 5; // OK
  final _label = 'hola mundo! BadImmutable', _bla = 5; // OK
}
```

**GOOD:**
```dart
class GoodMutable {
  var _label = 'hola mundo! GoodMutable';

  void changeLabel() {
    _label = 'hello world! GoodMutable';
  }
}
```

**BAD:**
```dart
class AssignedInAllConstructors {
  var _label; // LINT
  AssignedInAllConstructors(this._label);
  AssignedInAllConstructors.withDefault() : _label = 'Hello';
}
```

**GOOD:**
```dart
class NotAssignedInAllConstructors {
  var _label; // OK
  NotAssignedInAllConstructors();
  NotAssignedInAllConstructors.withDefault() : _label = 'Hello';
}
```
''';

bool _containedInFormal(Element element, FormalParameter formal) {
  var formalField = formal.identifier?.staticElement;
  return formalField is FieldFormalParameterElement &&
      formalField.field == element;
}

bool _containedInInitializer(
        Element element, ConstructorInitializer initializer) =>
    initializer is ConstructorFieldInitializer &&
    DartTypeUtilities.getCanonicalElementFromIdentifier(
            initializer.fieldName) ==
        element;

class PreferFinalFields extends LintRule {
  PreferFinalFields()
      : super(
            name: 'prefer_final_fields',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addCompilationUnit(this, visitor);
    registry.addFieldDeclaration(this, visitor);
  }
}

class _MutatedFieldsCollector extends RecursiveAstVisitor<void> {
  final Set<FieldElement> _mutatedFields;

  _MutatedFieldsCollector(this._mutatedFields);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _addMutatedFieldElement(node);
    super.visitAssignmentExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _addMutatedFieldElement(node);
    super.visitPostfixExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    var operator = node.operator;
    if (operator.type == TokenType.MINUS_MINUS ||
        operator.type == TokenType.PLUS_PLUS) {
      _addMutatedFieldElement(node);
    }
    super.visitPrefixExpression(node);
  }

  void _addMutatedFieldElement(CompoundAssignmentExpression assignment) {
    var element =
        DartTypeUtilities.getCanonicalElement(assignment.writeElement);
    if (element is FieldElement) {
      _mutatedFields.add(element);
    }
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  final Set<FieldElement> _mutatedFields = HashSet<FieldElement>();

  _Visitor(this.rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    node.accept(_MutatedFieldsCollector(_mutatedFields));
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (node.parent is EnumDeclaration) return;

    var fields = node.fields;
    if (fields.isFinal || fields.isConst) {
      return;
    }

    for (var variable in fields.variables) {
      var element = variable.declaredElement;

      if (element is PropertyInducingElement &&
          element.isPrivate &&
          !_mutatedFields.contains(element)) {
        bool fieldInConstructor(ConstructorDeclaration constructor) =>
            constructor.initializers.any((ConstructorInitializer initializer) =>
                _containedInInitializer(element, initializer)) ||
            constructor.parameters.parameters.any((FormalParameter formal) =>
                _containedInFormal(element, formal));

        var classDeclaration = node.parent;
        var constructors = classDeclaration is ClassDeclaration
            ? classDeclaration.members.whereType<ConstructorDeclaration>()
            : <ConstructorDeclaration>[];
        var isFieldInConstructors = constructors.any(fieldInConstructor);
        var isFieldInAllConstructors = constructors.every(fieldInConstructor);

        if (isFieldInConstructors) {
          if (isFieldInAllConstructors) {
            rule.reportLint(variable);
          }
        } else if (element.hasInitializer) {
          rule.reportLint(variable);
        }
      }
    }
  }
}
