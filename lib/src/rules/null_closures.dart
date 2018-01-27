// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.null_closures;

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

class NonNullableArguments {
  final String library;
  final String type;
  final String function;
  final List<int> positional;
  final List<String> named;

  NonNullableArguments(this.library, this.type, this.function,
      this.positional, this.named);

  NonNullableArguments.positions(
      this.library, this.type, this.function, this.positional)
      : named = <String>[];

  NonNullableArguments.names(this.library, this.type, this.function, this.named)
      : positional = <int>[];
}

final nonNullableConstructorArguments = [
  new NonNullableArguments.positions('dart.async', 'Future', null, [0]),
  new NonNullableArguments.positions('dart.async', 'Future', 'microtask', [0]),
  new NonNullableArguments.positions('dart.async', 'Future', 'sync', [0]),
  new NonNullableArguments.positions('dart.async', 'Timer', null, [1]),
  new NonNullableArguments.positions('dart.async', 'Timer', 'periodic', [1]),
  new NonNullableArguments.positions('dart.core', 'List', 'generate', [0]),
];

final nonNullableStaticFunctionArguments = [
  new NonNullableArguments.positions(
      'dart.async', null, 'scheduleMicrotask', [0]),
  new NonNullableArguments.positions('dart.async', 'Future', 'doWhile', [0]),
  new NonNullableArguments.positions('dart.async', 'Future', 'forEach', [1]),
  new NonNullableArguments.names('dart.async', 'Future', 'wait', ['cleanUp']),
  new NonNullableArguments.positions('dart.async', 'Timer', 'run', [0]),
  new NonNullableArguments.positions('dart.collection', 'Maps', 'forEach', [1]),
  new NonNullableArguments.positions('dart.collection', 'Maps', 'putIfAbsent', [2]),
];

final nonNullableInstanceFunctionArguments = [
  new NonNullableArguments('dart.async', 'Future', 'then', [0], ['onError']),
  new NonNullableArguments.positions(
      'dart.async', 'Future', 'whenComplete', [0]),
  new NonNullableArguments.positions('dart.collection', 'Queue', 'removeWhere', [0]),
  new NonNullableArguments.positions('dart.collection', 'Queue', 'retainWhere', [0]),
  new NonNullableArguments.positions('dart.collection', 'ListQueue', 'forEach', [0]),
  new NonNullableArguments.positions('dart.collection', 'ListQueue', 'removeWhere', [0]),
  new NonNullableArguments.positions('dart.collection', 'ListQueue', 'retainWhere', [0]),
  new NonNullableArguments.positions('dart.collection', 'MapView', 'forEach', [0]),
  new NonNullableArguments.positions('dart.collection', 'MapView', 'putIfAbsent', [1]),
  new NonNullableArguments.positions('dart.core', 'List', 'any', [0]),
  new NonNullableArguments.positions('dart.core', 'List', 'every', [0]),
  new NonNullableArguments.positions('dart.core', 'List', 'expand', [0]),
  new NonNullableArguments('dart.core', 'List', 'firstWhere', [0], ['orElse']),
  new NonNullableArguments.positions('dart.core', 'List', 'fold', [1]),
  new NonNullableArguments.positions('dart.core', 'List', 'forEach', [0]),
  new NonNullableArguments('dart.core', 'List', 'lastWhere', [0], ['orElse']),
  new NonNullableArguments.positions('dart.core', 'List', 'map', [0]),
  new NonNullableArguments.positions('dart.core', 'List', 'reduce', [0]),
  new NonNullableArguments.positions('dart.core', 'List', 'removeWhere', [0]),
  new NonNullableArguments.positions('dart.core', 'List', 'retainWhere', [0]),
  new NonNullableArguments.positions('dart.core', 'List', 'singleWhere', [0]),
  new NonNullableArguments.positions('dart.core', 'List', 'skipWhile', [0]),
  new NonNullableArguments.positions('dart.core', 'List', 'takeWhile', [0]),
  new NonNullableArguments.positions('dart.core', 'List', 'where', [0]),
  new NonNullableArguments.positions('dart.core', 'Map', 'forEach', [0]),
  new NonNullableArguments.positions('dart.core', 'Map', 'putIfAbsent', [1]),
  new NonNullableArguments.positions('dart.core', 'Set', 'removeWhere', [0]),
  new NonNullableArguments.positions('dart.core', 'Set', 'retainWhere', [0]),
  new NonNullableArguments.positions('dart.core', 'String', 'replaceAllMapped', [1]),
  new NonNullableArguments.positions('dart.core', 'String', 'replaceFirstMapped', [1]),
  new NonNullableArguments.names('dart.core', 'String', 'splitMapJoin', ['onMatch', 'onNonMatch']),
];

class NullClosures extends LintRule {
  NullClosures()
      : super(
            name: 'null_closures',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  final LintRule rule;
  Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    var constructorName = node.constructorName;
    var type = node.bestType;
    for (var arg in nonNullableConstructorArguments) {
      if (DartTypeUtilities.extendsClass(type, arg.type, arg.library)) {
        print('NAME ${constructorName?.name?.name}');
        if (constructorName?.name?.name == arg.function) {
          print('GEN ${node.bestType}');
          //_checkNullArgForClosure(node.argumentList, arg.position);
        }
      }
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    Expression target = node.target;
    print('start: $target');
    if (target == null || target is Identifier) {
      print('Static?');
      print('ID $target');
      Element elem = target?.bestElement;
      for (var arg in nonNullableStaticFunctionArguments) {
        if (elem is ClassElement && elem.name == arg.type) {
          if (node.methodName?.name == arg.function) {
            print('Y STTIC');
            //_checkNullArgForClosure(node.argumentList, arg.position);
          }
        }
      }
    } else {
      DartType type = node.target?.bestType;
      for (var arg in nonNullableInstanceFunctionArguments) {
        if (DartTypeUtilities.extendsClass(type, arg.type, arg.library)) {
          if (node.methodName?.name == arg.function) {
            print('yay! $type ${arg.function}');
            //_checkNullArgForClosure(node.argumentList, arg.position);
          }
        }
      }
    }
  }

  void _checkNullArgForClosure(ArgumentList node, List<int> positions, List<String> names) {
    NodeList<Expression> args = node.arguments;
    List<ParameterElement> params = node.correspondingStaticParameters;
    if (params == null) {
      return;
    }
    for (int i = 0; i < args.length; i++) {
      var arg = args[i];
      if (arg is NamedExpression) {
        arg = arg.expression;
      }
      if (arg is NullLiteral && params[i].type is FunctionType) {
        rule.reportLint(arg);
      }
    }
  }
}
