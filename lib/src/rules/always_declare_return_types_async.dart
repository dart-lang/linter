// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r'Declare method return types.';

const _details = r'''

**DO** declare method return types.

When declaring a method or function *always* specify a return type.
Declaring return types for functions helps improve your codebase by allowing the
analyzer to more adequately check your code for errors that could occur during
runtime.

**BAD:**
```dart
fetchAndParse() async {
  var data = await fetch();
  var serialized = serialize(data);
  return serialized;
}

class DataSerializer {
  fetchAndParse() async {
  var data = await fetch();
  var serialized = serialize(data);
  return serialized;
}
}
```

**GOOD:**
```dart
fetchAndParse() async {
  var data = await fetch();
  var serialized = serialize(data);
  return serialized;
}

_Foo _bar() => _Foo();

class _Foo {
  int _foo() => 42;
}

typedef predicate = bool Function(Object o);
```

''';

class AlwaysDeclareReturnTypesAsync extends LintRule implements NodeLintRule {
  AlwaysDeclareReturnTypesAsync()
      : super(
            name: 'always_declare_return_types_async',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addFunctionDeclaration(this, visitor);
    registry.addFunctionTypeAlias(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  static const LintCode functionCode = LintCode(
      "always_declare_return_types_async", // ignore: prefer_single_quotes
      "The async function {0} should have a return type but doesn't.",
      correction:
          "Try adding a return type to the function."); // ignore: prefer_single_quotes

  static const LintCode methodCode = LintCode(
      "always_declare_return_types_async", // ignore: prefer_single_quotes
      "The async method {0} should have a return type but doesn't.",
      correction:
          "Try adding a return type to the method."); // ignore: prefer_single_quotes

  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (!node.isSetter &&
        node.returnType == null &&
        _isAsync(node.declaredElement)) {
      rule.reportLint(node.name,
          arguments: [node.name.name], errorCode: functionCode);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (!node.isSetter &&
        node.returnType == null &&
        _isAsync(node.declaredElement) &&
        node.name.token.type != TokenType.INDEX_EQ) {
      rule.reportLint(node.name,
          arguments: [node.name.name], errorCode: methodCode);
    }
  }

  bool _isAsync(ExecutableElement? element) {
    if (element == null) {
      return false;
    }
    return element.isAsynchronous || element.isGenerator;
  }
}
