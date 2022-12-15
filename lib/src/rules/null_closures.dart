// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';

const _desc = r'Do not pass `null` as an argument where a closure is expected.';

const _details = r'''
**DON'T** pass `null` as an argument where a closure is expected.

Often a closure that is passed to a method will only be called conditionally,
so that tests and "happy path" production calls do not reveal that `null` will
result in an exception being thrown.

This rule only catches null literals being passed where closures are expected
in the following locations:

#### Static functions

* From `dart:async`
  * `Future.wait` at the named parameter `cleanup`

#### Instance methods

* From `dart:async`
  * `Future.then` at the named parameter `onError`
* From `dart:core`
  * `Iterable.firstWhere` at the named parameter `orElse`
  * `Iterable.lastWhere` at the named parameter `orElse`
  * `Iterable.singleWhere` at the named parameter `orElse`
  * `String.splitMapJoin` at the named parameters `onMatch` and `onNonMatch`

**BAD:**
```dart
[1, 3, 5].firstWhere((e) => e.isOdd, orElse: null);
```

**GOOD:**
```dart
[1, 3, 5].firstWhere((e) => e.isOdd, orElse: () => null);
```

''';

final Map<String, Set<NonNullableFunction>>
    _instanceMethodsWithNonNullableArguments = {
  'firstWhere': {
    NonNullableFunction('dart.core', 'Iterable', 'firstWhere',
        named: ['orElse']),
  },
  'lastWhere': {
    NonNullableFunction('dart.core', 'Iterable', 'lastWhere',
        named: ['orElse']),
  },
  'singleWhere': {
    NonNullableFunction('dart.core', 'Iterable', 'singleWhere',
        named: ['orElse']),
  },
  'splitMapJoin': {
    NonNullableFunction('dart.core', 'String', 'splitMapJoin',
        named: ['onMatch', 'onNonMatch']),
  },
  'then': {
    NonNullableFunction('dart.async', 'Future', 'then', named: ['onError']),
  },
};

List<NonNullableFunction> _staticFunctionsWithNonNullableArguments = [
  NonNullableFunction('dart.async', 'Future', 'wait', named: ['cleanUp']),
];

/// Function with closure parameters that cannot accept null arguments.
class NonNullableFunction {
  final String library;
  final String? type;
  final String? name;
  final List<String> named;

  NonNullableFunction(this.library, this.type, this.name,
      {this.named = const <String>[]});

  @override
  int get hashCode =>
      Object.hash(library.hashCode, type.hashCode, name.hashCode);

  /// Two [NonNullableFunction] objects are equal if their [library], [type],
  /// and [name] are equal, for the purpose of discovering whether a function
  /// invocation is among a collection of non-nullable functions.
  @override
  bool operator ==(Object other) =>
      other is NonNullableFunction && other.hashCode == hashCode;
}

class NullClosures extends LintRule {
  static const LintCode code = LintCode(
      'null_closures', "Closure can't be 'null' because it might be invoked.",
      correctionMessage: 'Try providing a non-null closure.');

  NullClosures()
      : super(
            name: 'null_closures',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    var target = node.target;
    var methodName = node.methodName.name;
    var element = target is Identifier ? target.staticElement : null;
    if (element is ClassElement) {
      // Static function called, "target" is the class.
      for (var function in _staticFunctionsWithNonNullableArguments) {
        if (methodName == function.name) {
          if (element.name == function.type) {
            _checkNullArgForClosure(node.argumentList, function.named);
          }
        }
      }
    } else {
      // Instance method called, "target" is the instance.
      var targetType = target?.staticType;
      var method = _getInstanceMethod(targetType, methodName);
      if (method == null) {
        return;
      }
      _checkNullArgForClosure(node.argumentList, method.named);
    }
  }

  void _checkNullArgForClosure(ArgumentList node, List<String> names) {
    var args = node.arguments;
    for (var i = 0; i < args.length; i++) {
      var arg = args[i];

      if (arg is NamedExpression) {
        if (arg.expression is NullLiteral &&
            names.contains(arg.name.label.name)) {
          rule.reportLint(arg);
        }
      }
    }
  }

  NonNullableFunction? _getInstanceMethod(DartType? type, String methodName) {
    var possibleMethods = _instanceMethodsWithNonNullableArguments[methodName];
    if (possibleMethods == null) {
      return null;
    }

    if (type is! InterfaceType) {
      return null;
    }

    NonNullableFunction? getMethod(String library, String className) =>
        possibleMethods
            .lookup(NonNullableFunction(library, className, methodName));

    var element = type.element;
    if (element.isSynthetic) {
      return null;
    }

    var method = getMethod(element.library.name, element.name);
    if (method != null) {
      return method;
    }

    for (var supertype in element.allSupertypes) {
      var superElement = supertype.element;
      method = getMethod(superElement.library.name, superElement.name);
      if (method != null) {
        return method;
      }
    }
    return null;
  }
}
