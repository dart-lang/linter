// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Specify type arguments for classes.';

const _details = r'''

**DO** specify type arguments for classes.

**GOOD:**
```
final a = <int>[];
final b = new List<int>();
final c = <int, String>{};
final d = new Map<int, String>();
```

**BAD:**
```
final a = [];
final b = new List();
final c = {};
final d = new Map();
```

NOTE: Using the the `@optionalTypeArgs` annotation in the `meta` package, API
authors can special-case type variables whose type needs to by dynamic but whose
declaration should be treated as optional. For example, suppose you have a
`Key` object whose type parameter you'd like to treat as optional. Using the
`@optionalTypeArgs` would look like this:

```
import 'package:meta/meta.dart';

@optionalTypeArgs
class Key<T> {
 ...
}

main() {
  Key s = new Key(); // OK!
}
```

''';

/// The name of `meta` library, used to define analysis annotations.
String _META_LIB_NAME = 'meta';

/// The name of the top-level variable used to mark a Class as having optional
/// type args.
String _OPTIONAL_TYPE_ARGS_VAR_NAME = 'optionalTypeArgs';

bool _isOptionallyParameterized(ParameterizedType type) {
  List<ElementAnnotation> metadata = type.element?.metadata;
  if (metadata != null) {
    return metadata
        .any((ElementAnnotation a) => _isOptionalTypeArgs(a.element));
  }
  return false;
}

bool _isOptionalTypeArgs(Element element) =>
    element is PropertyAccessorElement &&
    element.name == _OPTIONAL_TYPE_ARGS_VAR_NAME &&
    element.library?.name == _META_LIB_NAME;

class AlwaysSpecifyTypeArgumentsForClasses extends LintRule
    implements NodeLintRule {
  AlwaysSpecifyTypeArgumentsForClasses()
      : super(
            name: 'always_specify_type_arguments_for_classes',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addListLiteral(this, visitor);
    registry.addMapLiteral(this, visitor);
    registry.addTypeName(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitListLiteral(ListLiteral literal) {
    _checkLiteral(literal);
  }

  @override
  void visitMapLiteral(MapLiteral literal) {
    _checkLiteral(literal);
  }

  void _checkLiteral(TypedLiteral literal) {
    if (literal.typeArguments == null) {
      rule.reportLintForToken(literal.beginToken);
    }
  }

  // Future kernel API.
  void visitNamedType(NamedType namedType) {
    DartType type = namedType.type;
    if (type is ParameterizedType) {
      if (type.typeParameters.isNotEmpty &&
          namedType.typeArguments == null &&
          namedType.parent is! IsExpression &&
          !_isOptionallyParameterized(type)) {
        rule.reportLint(namedType);
      }
    }
  }

  @override
  void visitTypeName(NamedType typeName) {
    visitNamedType(typeName);
  }
}
