// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Specify type arguments for methods.';

const _details = r'''

**DO** specify type arguments for methods.

**GOOD:**
```
void m<T>(T t1, T t2) {}
m<int>(1, 2);
```

**BAD:**
```
void m<T>(T t1, T t2) {}
m(1, 2);
```

NOTE: Using the the `@optionalTypeArgs` annotation in the `meta` package, API
authors can special-case type variables whose type needs to by dynamic but whose
declaration should be treated as optional. For example, suppose you have a
`m` function whose type parameter you'd like to treat as optional. Using the
`@optionalTypeArgs` would look like this:

```
import 'package:meta/meta.dart';

@optionalTypeArgs
void m<T>(T t1, T t2) {}

main() {
  m(1, 2); // OK!
}
```

''';

/// The name of `meta` library, used to define analysis annotations.
String _META_LIB_NAME = 'meta';

/// The name of the top-level variable used to mark a Class as having optional
/// type args.
String _OPTIONAL_TYPE_ARGS_VAR_NAME = 'optionalTypeArgs';

bool _isOptionalTypeArgs(Element element) =>
    element is PropertyAccessorElement &&
    element.name == _OPTIONAL_TYPE_ARGS_VAR_NAME &&
    element.library?.name == _META_LIB_NAME;

class AlwaysSpecifyTypeArgumentsForMethods extends LintRule
    implements NodeLintRule {
  AlwaysSpecifyTypeArgumentsForMethods()
      : super(
            name: 'always_specify_type_arguments_for_methods',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.typeArguments == null) {
      final element = node.methodName.bestElement;
      if (element is FunctionTypedElement &&
          element.typeParameters.isNotEmpty &&
          !element.metadata.any((a) => _isOptionalTypeArgs(a.element))) {
        rule.reportLint(node.methodName);
      }
    }
  }
}
