// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

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
}

class _Visitor extends SimpleAstVisitor<void> {
  static const LintCode keywordCouldBeTypeCode = LintCode(
      "always_specify_types", "'{0}' could be '{1}'.",
      correction: "Try changing the type.");

  static const LintCode keywordCouldBeSplitToTypesCode = LintCode(
      "always_specify_types", "'{0}' could be split into types.",
      correction: "Try splitting '{0}' to different types.");

  static const LintCode specifyTypeCode = LintCode(
      "always_specify_types", "Specify '{0}' type.",
      correction: "Try specifying the type.");

  final LintRule rule;

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
        if (keyword.keyword == Keyword.VAR) {
          rule.reportLintForToken(keyword,
              arguments: [keyword, element.type],
              errorCode: keywordCouldBeTypeCode);
        } else {
          rule.reportLintForToken(keyword,
              arguments: [element.type], errorCode: specifyTypeCode);
        }
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

        if (keyword.type == Keyword.VAR &&
            type != null &&
            type is! DynamicType) {
          rule.reportLintForToken(keyword,
              arguments: [keyword, type], errorCode: keywordCouldBeTypeCode);
        } else {
          rule.reportLintForToken(keyword);
        }
      } else if (param.declaredElement != null) {
        var type = param.declaredElement!.type;

        if (type is DynamicType) {
          rule.reportLint(param);
        } else {
          rule.reportLint(param, arguments: [type], errorCode: specifyTypeCode);
        }
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
      Set<String>? types;
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

      var singleType = types.length == 1;

      List<Object> arguments;
      ErrorCode? errorCode;
      if (types.isEmpty) {
        arguments = [];
      } else if (keyword.type == Keyword.VAR) {
        if (singleType) {
          arguments = [keyword, types.first];
          errorCode = keywordCouldBeTypeCode;
        } else {
          arguments = [keyword];
          errorCode = keywordCouldBeSplitToTypesCode;
        }
      } else {
        if (singleType) {
          arguments = [types.first];
          errorCode = specifyTypeCode;
        } else {
          arguments = [];
        }
      }
      rule.reportLintForToken(keyword,
          arguments: arguments, errorCode: errorCode);
    }
  }

  Set<String> _getTypes(VariableDeclarationList list) {
    var types = <String>{};
    for (var variable in list.variables) {
      var type = variable.initializer?.staticType;
      if (type != null) {
        types.add(type.getDisplayString(withNullability: false));
      }
    }
    return types;
  }
}
