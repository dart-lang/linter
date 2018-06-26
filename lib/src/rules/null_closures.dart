// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/ast/ast.dart' show ArgumentListImpl;
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

class NonNullableArguments {
  final String library;
  final String type;
  final String function;
  final List<int> positional;
  final List<String> named;

  const NonNullableArguments(this.library, this.type, this.function,
      {this.positional: const <int>[], this.named: const <String>[]});
}

List<NonNullableArguments> _nonNullableConstructorArguments =
     <NonNullableArguments>[
  new NonNullableArguments('dart.async', 'Future', null, positional: [0]),
  new NonNullableArguments('dart.async', 'Future', 'microtask',
      positional: [0]),
  new NonNullableArguments('dart.async', 'Future', 'sync', positional: [0]),
  new NonNullableArguments('dart.async', 'Timer', null, positional: [1]),
  new NonNullableArguments('dart.async', 'Timer', 'periodic',
      positional: [1]),
  new NonNullableArguments('dart.core', 'List', 'generate', positional: [1]),
];

List<NonNullableArguments> _nonNullableStaticFunctionArguments =
    <NonNullableArguments>[
  new NonNullableArguments('dart.async', null, 'scheduleMicrotask',
      positional: [0]),
  new NonNullableArguments('dart.async', 'Future', 'doWhile', positional: [0]),
  new NonNullableArguments('dart.async', 'Future', 'forEach', positional: [1]),
  new NonNullableArguments('dart.async', 'Future', 'wait', named: ['cleanUp']),
  new NonNullableArguments('dart.async', 'Timer', 'run', positional: [0]),
];

List<NonNullableArguments> _nonNullableInstanceFunctionArguments =
    <NonNullableArguments>[
  new NonNullableArguments('dart.async', 'Future', 'then',
      positional: const [0], named: const ['onError']),
  new NonNullableArguments('dart.async', 'Future', 'complete', positional: [0]),
  new NonNullableArguments('dart.collection', 'Queue', 'removeWhere',
      positional: [0]),
  new NonNullableArguments('dart.collection', 'Queue', 'retainWhere',
      positional: [0]),
  new NonNullableArguments('dart.collection', 'ListQueue', 'forEach',
      positional: [0]),
  new NonNullableArguments('dart.collection', 'ListQueue', 'removeWhere',
      positional: [0]),
  new NonNullableArguments('dart.collection', 'ListQueue', 'retainWhere',
      positional: [0]),
  new NonNullableArguments('dart.collection', 'MapView', 'forEach',
      positional: [0]),
  new NonNullableArguments('dart.collection', 'MapView', 'putIfAbsent',
      positional: [1]),
  new NonNullableArguments('dart.core', 'List', 'any', positional: [0]),
  new NonNullableArguments('dart.core', 'List', 'every', positional: [0]),
  new NonNullableArguments('dart.core', 'List', 'expand', positional: [0]),
  new NonNullableArguments('dart.core', 'List', 'firstWhere',
      positional: const [0], named: const ['orElse']),
  new NonNullableArguments('dart.core', 'List', 'fold', positional: [1]),
  new NonNullableArguments('dart.core', 'List', 'forEach', positional: [0]),
  new NonNullableArguments('dart.core', 'List', 'lastWhere',
      positional: [0], named: ['orElse']),
  new NonNullableArguments('dart.core', 'List', 'map', positional: [0]),
  new NonNullableArguments('dart.core', 'List', 'reduce', positional: [0]),
  new NonNullableArguments('dart.core', 'List', 'removeWhere', positional: [0]),
  new NonNullableArguments('dart.core', 'List', 'retainWhere', positional: [0]),
  new NonNullableArguments('dart.core', 'List', 'singleWhere', positional: [0]),
  new NonNullableArguments('dart.core', 'List', 'skipWhile', positional: [0]),
  new NonNullableArguments('dart.core', 'List', 'takeWhile', positional: [0]),
  new NonNullableArguments('dart.core', 'List', 'where', positional: [0]),
  new NonNullableArguments('dart.core', 'Map', 'forEach', positional: [0]),
  new NonNullableArguments('dart.core', 'Map', 'putIfAbsent', positional: [1]),
  new NonNullableArguments('dart.core', 'Set', 'removeWhere', positional: [0]),
  new NonNullableArguments('dart.core', 'Set', 'retainWhere', positional: [0]),
  new NonNullableArguments('dart.core', 'String', 'replaceAllMapped',
      positional: [1]),
  new NonNullableArguments('dart.core', 'String', 'replaceFirstMapped',
      positional: [1]),
  new NonNullableArguments('dart.core', 'String', 'splitMapJoin',
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
    for (var arg in _nonNullableConstructorArguments) {
      if (DartTypeUtilities.extendsClass(type, arg.type, arg.library)) {
        if (constructorName?.name?.name == arg.function) {
          _checkNullArgForClosure(node.argumentList, arg.positional, arg.named);
        }
      }
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    Expression target = node.target;
    String methodName = node.methodName?.name;
    if (target == null || target is Identifier) {
      Element element = target?.bestElement;
      DartType type = target?.bestType;
      if (element is ClassElement) {
        // Static function called, "target" is the class.
        for (var arg in _nonNullableStaticFunctionArguments) {
          if (element.name == arg.type) {
            if (methodName == arg.function) {
              _checkNullArgForClosure(node.argumentList, arg.positional, arg.named);
            }
          }
        }
      } else {
        // Instance method called, "target" is the instance.
        for (var arg in _nonNullableInstanceFunctionArguments) {
          if (DartTypeUtilities.extendsClass(type, arg.type, arg.library)) {
            if (methodName == arg.function) {
              _checkNullArgForClosure(
                  node.argumentList, arg.positional, arg.named);
            }
          }
        }
      }
    } else {
      DartType type = node.target?.bestType;
      for (var arg in _nonNullableInstanceFunctionArguments) {
        if (DartTypeUtilities.extendsClass(type, arg.type, arg.library)) {
          if (methodName == arg.function) {
            _checkNullArgForClosure(
                node.argumentList, arg.positional, arg.named);
          }
        }
      }
    }
  }

  void _checkNullArgForClosure(
      ArgumentListImpl node, List<int> positions, List<String> names) {
    NodeList<Expression> args = node.arguments;
    List<ParameterElement> params = node.correspondingStaticParameters;
    if (params == null) {
      params = node.correspondingPropagatedParameters;
      if (params == null) {
        return;
      }
    }
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
