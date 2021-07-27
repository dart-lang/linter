// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';

const _desc =
    r'Avoid <Type>.toString() in production code since results may be minified.';

const _details = r'''

**DO** avoid calls to <Type>.toString() in production code, since it does not
contractually return the user-defined name of the Type (or underlying class).
Development-mode compilers where code size is not a concern use the full name,
but release-mode compilers often choose to minify these symbols.

**BAD:**
```dart
void bar(Object other) {
  if (other.runtimeType.toString() == 'Bar') {
    doThing();
  }
}

Object baz(Thing myThing) {
  return getThingFromDatabase(key: myThing.runtimeType.toString());
}
```

**GOOD:**
```dart
void bar(Object other) {
  if (other is Bar) {
    doThing();
  }
}

class Thing {
  String get thingTypeKey => ...
}

Object baz(Thing myThing) {
  return getThingFromDatabase(key: myThing.thingTypeKey);
}
```

''';

class AvoidTypeToString extends LintRule implements NodeLintRule {
  AvoidTypeToString()
      : super(
            name: 'avoid_type_to_string',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor =
        _Visitor(this, context.typeSystem, context.typeProvider.typeType);
    registry.addArgumentList(this, visitor);
    // Also delegates to visitArgumentList.
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  final TypeSystem typeSystem;
  final InterfaceType typeType;

  // Null if there is no logical `this` in the given context.
  DartType? thisType;

  _Visitor(this.rule, this.typeSystem, this.typeType);

  DartType? getThisType(MethodInvocation node) {
    AstNode? parent = node;
    while (parent != null) {
      if (parent is ClassOrMixinDeclaration) {
        return parent.declaredElement?.thisType;
      }
      if (parent is ExtensionDeclaration) {
        return parent.declaredElement?.extendedType;
      }
      parent = parent.parent;
    }

    return null;
  }

  @override
  void visitArgumentList(ArgumentList node) {
    node.arguments.forEach(_validateArgument);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    thisType = getThisType(node);

    visitArgumentList(node.argumentList);

    var staticType = node.realTarget?.staticType;
    var targetType = staticType is InterfaceType ? staticType : thisType;
    _reportIfToStringOnCoreTypeClass(targetType, node.methodName);
  }

  bool _isSimpleIdDeclByCoreObj(SimpleIdentifier simpleIdentifier) {
    var encloser = simpleIdentifier.staticElement?.enclosingElement;
    return encloser is ClassElement && encloser.isDartCoreObject;
  }

  bool _isToStringOnCoreTypeClass(
          DartType? targetType, SimpleIdentifier methodIdentifier) =>
      targetType != null &&
      methodIdentifier.name == 'toString' &&
      _isSimpleIdDeclByCoreObj(methodIdentifier) &&
      typeSystem.isSubtypeOf(targetType, typeType);

  void _reportIfToStringOnCoreTypeClass(
      DartType? targetType, SimpleIdentifier methodIdentifier) {
    if (_isToStringOnCoreTypeClass(targetType, methodIdentifier)) {
      rule.reportLint(methodIdentifier);
    }
  }

  void _validateArgument(Expression expression) {
    if (expression is PropertyAccess) {
      var expressionType = expression.realTarget.staticType;
      var targetType =
          (expressionType is InterfaceType) ? expressionType : thisType;
      _reportIfToStringOnCoreTypeClass(targetType, expression.propertyName);
    } else if (expression is PrefixedIdentifier) {
      var prefixType = expression.prefix.staticType;
      if (prefixType is InterfaceType) {
        _reportIfToStringOnCoreTypeClass(prefixType, expression.identifier);
      }
    } else if (expression is SimpleIdentifier) {
      _reportIfToStringOnCoreTypeClass(thisType, expression);
    }
  }
}
