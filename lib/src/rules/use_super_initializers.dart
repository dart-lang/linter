// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r'Use super-initializer parameters where possible.';

const _details = r'''
"Forwarding constructor"s, that do nothing except forward parameters to their 
superclass constructors should take advantage of super-initializer parameters 
rather than repeating the names of parameters when passing them to the 
superclass constructors.  This makes the code more concise and easier to read
and maintain.

**DO** use super-initializer parameters where possible.

**BAD:**
```dart
class A {
  A({int? x, int? y});
}
class B extends A {
  B({int? x, int? y}) : super(x: x, y: y);
}
```

**GOOD:**
```dart
class A {
  A({int? x, int? y});
}
class B extends A {
  B({super.x, int? y}) : super(y: y);
}
```
''';

class UseSuperInitializers extends LintRule {
  UseSuperInitializers()
      : super(
            name: 'use_super_initializers',
            description: _desc,
            details: _details,
            maturity: Maturity.experimental,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    if (!context.isEnabled(Feature.super_parameters)) return;

    var visitor = _Visitor(this, context);
    registry.addConstructorDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LinterContext context;
  final LintRule rule;

  _Visitor(this.rule, this.context);

  void check(
      SuperConstructorInvocation initializer, FormalParameterList parameters) {
    var constructorElement = initializer.staticElement;
    if (constructorElement == null) return;

    for (var parameter in parameters.parameters) {
      var parameterElement = parameter.declaredElement;
      if (parameterElement == null) continue;

      // todo(pq): consolidate logic shared w/ server (https://github.com/dart-lang/linter/issues/3263)
      if (parameterElement.isPositional) {
        if (_checkPositionalParameter(
            parameter, parameterElement, constructorElement, initializer)) {
          rule.reportLint(initializer);
        }
      } else if (parameterElement.isNamed) {
        if (_checkNamedParameter(
            parameter, parameterElement, constructorElement, initializer)) {
          rule.reportLint(initializer);
        }
      }
    }
  }

  @override
  visitConstructorDeclaration(ConstructorDeclaration node) {
    var parameters = node.parameters;

    var initializers = node.initializers;
    for (var initializer in initializers) {
      if (initializer is SuperConstructorInvocation) {
        check(initializer, parameters);
      }
    }
  }

  /// Return `true` if the named [parameter] can be converted into a super
  /// initializing formal parameter.
  bool _checkNamedParameter(
      FormalParameter parameter,
      ParameterElement thisParameter,
      ConstructorElement superConstructor,
      SuperConstructorInvocation superInvocation) {
    var superParameter =
        _correspondingNamedParameter(superConstructor, thisParameter);
    if (superParameter == null) return false;

    bool matchingArgument = false;
    var arguments = superInvocation.argumentList.arguments;
    for (var argument in arguments) {
      if (argument is NamedExpression &&
          argument.name.label.name == thisParameter.name) {
        var expression = argument.expression;
        if (expression is SimpleIdentifier &&
            expression.staticElement == thisParameter) {
          matchingArgument = true;
          break;
        }
      }
    }
    if (!matchingArgument) {
      // If the selected parameter isn't being passed to the super constructor,
      // then don't lint.
      return false;
    }

    // Compare the types.
    var superType = superParameter.type;
    var thisType = thisParameter.type;
    if (!context.typeSystem.isAssignableTo(superType, thisType)) {
      // If the type of the selected parameter can't be assigned to the super
      // parameter, then don't lint.
      return false;
    }

    return true;
  }

  /// Return `true` if the positional [parameter] can be converted into a super
  /// initializing formal parameter.
  bool _checkPositionalParameter(
      FormalParameter parameter,
      ParameterElement thisParameter,
      ConstructorElement superConstructor,
      SuperConstructorInvocation superInvocation) {
    var positionalArguments = _positionalArguments(superInvocation);
    if (positionalArguments.length != 1) {
      // If there's more than one positional parameter then they would all need
      // to be converted at the same time. If there's less than one, the the
      // selected parameter isn't being passed to the super constructor.
      return false;
    }
    var argument = positionalArguments[0];
    if (argument is! SimpleIdentifier ||
        argument.staticElement != parameter.declaredElement) {
      // If the selected parameter isn't the one being passed to the super
      // constructor then the change isn't appropriate.
      return false;
    }
    var positionalParameters = superConstructor.parameters
        .where((param) => param.isPositional)
        .toList();
    if (positionalParameters.isEmpty) {
      return false;
    }

    var superParameter = positionalParameters[0];
    // Compare the types.
    var superType = superParameter.type;
    var thisType = thisParameter.type;
    if (!context.typeSystem.isSubtypeOf(thisType, superType)) {
      // If the type of the selected parameter can't be assigned to the super
      // parameter, the the change isn't appropriate.
      return false;
    }

    return true;
  }

  ParameterElement? _correspondingNamedParameter(
      ConstructorElement superConstructor, ParameterElement thisParameter) {
    for (var superParameter in superConstructor.parameters) {
      if (superParameter.isNamed && superParameter.name == thisParameter.name) {
        return superParameter;
      }
    }
    return null;
  }

  List<Expression> _positionalArguments(
          SuperConstructorInvocation invocation) =>
      invocation.argumentList.arguments
          .where((argument) => argument is! NamedExpression)
          .toList();
}
