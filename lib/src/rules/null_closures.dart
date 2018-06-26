// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

const _desc = r'Do not pass `null` as an argument where a closure is expected.';

const _details = r'''

**DO NOT** pass null as an argument where a closure is expected.

Often a closure that is passed to a method will only be called conditionally,
so that tests and "happy path" production calls do not reveal that `null` will
result in an exception being thrown.

This rule only catches null literals being passed where closures are expected.

**BAD:**
```
[1, 3, 5].firstWhere((e) => e.isOdd, orElse: null);
```

**GOOD:**
```
[1, 3, 5].firstWhere((e) => e.isOdd, orElse: () => null);
```

''';

/// Function with closure parameters that cannot accept null arguments.
class NonNullableFunction {
  final String library;
  final String type;
  final String name;
  final List<int> positional;
  final List<String> named;

  const NonNullableFunction(this.library, this.type, this.name,
      {this.positional: const <int>[], this.named: const <String>[]});
}

List<NonNullableFunction> _constructorsWithNonNullableArguments =
    <NonNullableFunction>[
  new NonNullableFunction('dart.async', 'Future', null, positional: [0]),
  new NonNullableFunction('dart.async', 'Future', 'microtask', positional: [0]),
  new NonNullableFunction('dart.async', 'Future', 'sync', positional: [0]),
  new NonNullableFunction('dart.async', 'Timer', null, positional: [1]),
  new NonNullableFunction('dart.async', 'Timer', 'periodic', positional: [1]),
  new NonNullableFunction('dart.core', 'List', 'generate', positional: [1]),
];

List<NonNullableFunction> _staticFunctionsWithNonNullableArguments =
    <NonNullableFunction>[
  new NonNullableFunction('dart.async', null, 'scheduleMicrotask',
      positional: [0]),
  new NonNullableFunction('dart.async', 'Future', 'doWhile', positional: [0]),
  new NonNullableFunction('dart.async', 'Future', 'forEach', positional: [1]),
  new NonNullableFunction('dart.async', 'Future', 'wait', named: ['cleanUp']),
  new NonNullableFunction('dart.async', 'Timer', 'run', positional: [0]),
];

List<NonNullableFunction> _instanceMethodsWithNonNullableArguments =
    <NonNullableFunction>[
  new NonNullableFunction('dart.async', 'Future', 'then',
      positional: const [0], named: const ['onError']),
  new NonNullableFunction('dart.async', 'Future', 'complete', positional: [0]),
  new NonNullableFunction('dart.collection', 'Queue', 'removeWhere',
      positional: [0]),
  new NonNullableFunction('dart.collection', 'Queue', 'retainWhere',
      positional: [0]),
  new NonNullableFunction('dart.collection', 'ListQueue', 'forEach',
      positional: [0]),
  new NonNullableFunction('dart.collection', 'ListQueue', 'removeWhere',
      positional: [0]),
  new NonNullableFunction('dart.collection', 'ListQueue', 'retainWhere',
      positional: [0]),
  new NonNullableFunction('dart.collection', 'MapView', 'forEach',
      positional: [0]),
  new NonNullableFunction('dart.collection', 'MapView', 'putIfAbsent',
      positional: [1]),
  new NonNullableFunction('dart.core', 'List', 'any', positional: [0]),
  new NonNullableFunction('dart.core', 'List', 'every', positional: [0]),
  new NonNullableFunction('dart.core', 'List', 'expand', positional: [0]),
  new NonNullableFunction('dart.core', 'List', 'firstWhere',
      positional: const [0], named: const ['orElse']),
  new NonNullableFunction('dart.core', 'List', 'fold', positional: [1]),
  new NonNullableFunction('dart.core', 'List', 'forEach', positional: [0]),
  new NonNullableFunction('dart.core', 'List', 'lastWhere',
      positional: [0], named: ['orElse']),
  new NonNullableFunction('dart.core', 'List', 'map', positional: [0]),
  new NonNullableFunction('dart.core', 'List', 'reduce', positional: [0]),
  new NonNullableFunction('dart.core', 'List', 'removeWhere', positional: [0]),
  new NonNullableFunction('dart.core', 'List', 'retainWhere', positional: [0]),
  new NonNullableFunction('dart.core', 'List', 'singleWhere', positional: [0]),
  new NonNullableFunction('dart.core', 'List', 'skipWhile', positional: [0]),
  new NonNullableFunction('dart.core', 'List', 'takeWhile', positional: [0]),
  new NonNullableFunction('dart.core', 'List', 'where', positional: [0]),
  new NonNullableFunction('dart.core', 'Map', 'forEach', positional: [0]),
  new NonNullableFunction('dart.core', 'Map', 'putIfAbsent', positional: [1]),
  new NonNullableFunction('dart.core', 'Set', 'removeWhere', positional: [0]),
  new NonNullableFunction('dart.core', 'Set', 'retainWhere', positional: [0]),
  new NonNullableFunction('dart.core', 'String', 'replaceAllMapped',
      positional: [1]),
  new NonNullableFunction('dart.core', 'String', 'replaceFirstMapped',
      positional: [1]),
  new NonNullableFunction('dart.core', 'String', 'splitMapJoin',
      named: ['onMatch', 'onNonMatch']),
];

class NullClosures extends LintRule implements NodeLintRule {
  NullClosures()
      : super(
            name: 'null_closures',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addInstanceCreationExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    var constructorName = node.constructorName;
    var type = node.bestType;
    for (var constructor in _constructorsWithNonNullableArguments) {
      if (DartTypeUtilities.extendsClass(
          type, constructor.type, constructor.library)) {
        if (constructorName?.name?.name == constructor.name) {
          _checkNullArgForClosure(
              node.argumentList, constructor.positional, constructor.named);
        }
      }
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    Expression target = node.target;
    String methodName = node.methodName?.name;
    Element element = target is Identifier ? target?.bestElement : null;
    if (element is ClassElement) {
      // Static function called, "target" is the class.
      for (var function in _staticFunctionsWithNonNullableArguments) {
        if (element.name == function.type) {
          if (methodName == function.name) {
            _checkNullArgForClosure(
                node.argumentList, function.positional, function.named);
          }
        }
      }
    } else {
      // Instance method called, "target" is the instance.
      DartType targetType = target?.bestType;
      for (var method in _instanceMethodsWithNonNullableArguments) {
        if (DartTypeUtilities.extendsClass(
            targetType, method.type, method.library)) {
          if (methodName == method.name) {
            _checkNullArgForClosure(
                node.argumentList, method.positional, method.named);
          }
        }
      }
    }
  }

  void _checkNullArgForClosure(
      ArgumentList node, List<int> positions, List<String> names) {
    NodeList<Expression> args = node.arguments;
    for (int i = 0; i < args.length; i++) {
      Expression arg = args[i];

      if (arg is NamedExpression) {
        if (arg.expression is NullLiteral &&
            names.contains(arg.name.label.name)) {
          rule.reportLint(arg);
        }
      } else {
        if (arg is NullLiteral && positions.contains(i)) {
          rule.reportLint(arg);
        }
      }
    }
  }
}
