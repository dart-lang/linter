// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';
import '../utils.dart';

const _desc = r'Specify type annotations.';

const _details = r'''

From the [flutter style guide](https://flutter.dev/style-guide/):

**DO** specify type annotations.

Avoid `var` when specifying that a type is unknown and short-hands that elide
type annotations.  Use `dynamic` if you are being explicit that the type is
unknown.  Use `Object` if you are being explicit that you want an object that
implements `==` and `hashCode`.

**GOOD:**
```dart
int foo = 10;
final Bar bar = Bar();
String baz = 'hello';
const int quux = 20;
```

**BAD:**
```dart
var foo = 10;
final bar = Bar();
const quux = 20;
```

NOTE: Using the the `@optionalTypeArgs` annotation in the `meta` package, API
authors can special-case type variables whose type needs to by dynamic but whose
declaration should be treated as optional.  For example, suppose you have a
`Key` object whose type parameter you'd like to treat as optional.  Using the
`@optionalTypeArgs` would look like this:

```dart
import 'package:meta/meta.dart';

@optionalTypeArgs
class Key<T> {
 ...
}

main() {
  Key s = Key(); // OK!
}
```

''';

/// The name of `meta` library, used to define analysis annotations.
String _metaLibName = 'meta';

/// The name of the top-level variable used to mark a Class as having optional
/// type args.
String _optionalTypeArgsVarName = 'optionalTypeArgs';

bool _isOptionallyParameterized(TypeParameterizedElement element) {
  var metadata = element.metadata;
  return metadata.any((ElementAnnotation a) => _isOptionalTypeArgs(a.element));
}

bool _isOptionalTypeArgs(Element? element) =>
    element is PropertyAccessorElement &&
    element.name == _optionalTypeArgsVarName &&
    element.library.name == _metaLibName;

class AlwaysSpecifyTypes extends LintRule {
  AlwaysSpecifyTypes()
      : super(
            name: 'always_specify_types',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  List<String> get incompatibleRules =>
      const ['avoid_types_on_closure_parameters', 'omit_local_variable_types'];

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addDeclaredIdentifier(this, visitor);
    registry.addListLiteral(this, visitor);
    registry.addSetOrMapLiteral(this, visitor);
    registry.addSimpleFormalParameter(this, visitor);
    registry.addTypeName(this, visitor);
    registry.addVariableDeclarationList(this, visitor);
  }

  void _reportLintForTokenWithDescription(Token token, String description) {
    reporter.reportErrorForToken(LintCode(name, description), token);
  }

  void _reportLintForNodeWithDescription(AstNode node, String description) {
    reporter.reportErrorForNode(LintCode(name, description), node);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AlwaysSpecifyTypes rule;

  _Visitor(this.rule);

  void checkLiteral(TypedLiteral literal) {
    if (literal.typeArguments == null) {
      rule.reportLintForToken(literal.beginToken);
    }
  }

  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    var keyword = node.keyword;
    if (node.type == null && keyword != null) {
      var element = node.identifier.staticElement;
      if (element is VariableElement) {
        var description = keyword.keyword == Keyword.VAR
            ? "'$keyword' could be '${element.type}'."
            : "Specify '${element.type}' type.";

        rule._reportLintForTokenWithDescription(keyword, description);
      }
    }
  }

  @override
  void visitListLiteral(ListLiteral literal) {
    checkLiteral(literal);
  }

  void visitNamedType(NamedType namedType) {
    var type = namedType.type;
    if (type is InterfaceType) {
      var element = type.aliasElement ?? type.element;
      if (element.typeParameters.isNotEmpty &&
          namedType.typeArguments == null &&
          namedType.parent is! IsExpression &&
          !_isOptionallyParameterized(element)) {
        rule.reportLint(namedType);
      }
    }
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral literal) {
    checkLiteral(literal);
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter param) {
    var identifier = param.identifier;
    if (identifier != null &&
        param.type == null &&
        !isJustUnderscores(identifier.name)) {
      if (param.keyword != null) {
        var keyword = param.keyword!;
        var type = param.declaredElement?.type;
        var description = keyword.type == Keyword.VAR && type != null
            ? "'${param.keyword}' could be '$type'."
            : _desc;
        rule._reportLintForTokenWithDescription(param.keyword!, description);
      } else if (param.declaredElement != null) {
        var type = param.declaredElement!.type;
        rule._reportLintForNodeWithDescription(
            param, type is DynamicType ? _desc : "Specify '$type' type.");
      }
    }
  }

  @override
  void visitTypeName(NamedType typeName) {
    visitNamedType(typeName);
  }

  @override
  void visitVariableDeclarationList(VariableDeclarationList list) {
    var keyword = list.keyword;
    if (list.type == null && keyword != null) {
      List<String>? types;
      var parent = list.parent;
      if (parent is TopLevelVariableDeclaration) {
        types = _getTypes(parent.variables);
      } else if (parent is ForPartsWithDeclarations) {
        types = _getTypes(parent.variables);
      } else if (parent is FieldDeclaration) {
        types = _getTypes(parent.fields);
      } else if (parent is VariableDeclarationStatement) {
        types = _getTypes(parent.variables);
      }

      if (types == null) return;

      String? multipleTypesString;
      if (types.toSet().length > 1) {
        multipleTypesString =
            "${types.take(types.length - 1).map((e) => "'$e'").join(", ")} and '${types.last}'";
      }
      String description;
      if (types.isEmpty) {
        description = _desc;
      } else if (keyword.type == Keyword.VAR) {
        description = multipleTypesString == null
            ? "'${list.keyword}' could be '${types.first}'."
            : "'${list.keyword}' could be split into $multipleTypesString.";
      } else {
        description = multipleTypesString == null
            ? "Specify '${types.first}' type."
            : 'Specify $multipleTypesString types.';
      }
      rule._reportLintForTokenWithDescription(keyword, description);
    }
  }

  List<String> _getTypes(VariableDeclarationList list) {
    var types = <String>[];
    for (var variable in list.variables) {
      var type = variable.initializer?.staticType;
      if (type != null) {
        types.add(type.getDisplayString(withNullability: false));
      }
    }
    return types;
  }
}
