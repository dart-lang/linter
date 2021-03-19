// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r'Avoid using private types in public APIs.';

const _details = r'''

**AVOID** using private types in public APIs.

**GOOD:**
```
f(String s) { ... }
```

**BAD:**
```
f(_Private p) { ... }
class _Private {}
```

''';

class LibraryPrivateTypeInPublicAPI extends LintRule implements NodeLintRule {
  LibraryPrivateTypeInPublicAPI()
      : super(
            name: 'library_private_types_in_public_api',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    final visitor = Visitor(this);
    registry.addCompilationUnit(this, visitor);
  }
}

class Validator extends SimpleAstVisitor<void> {
  LintRule rule;

  Validator(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (Identifier.isPrivateName(node.name.name)) {
      return;
    }
    node.typeParameters?.accept(this);
    node.members.accept(this);
  }

  @override
  void visitClassTypeAlias(ClassTypeAlias node) {
    if (Identifier.isPrivateName(node.name.name)) {
      return;
    }
    node.superclass.accept(this);
    node.typeParameters?.accept(this);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    var name = node.name;
    if (name != null && Identifier.isPrivateName(name.name)) {
      return;
    }
    node.parameters.accept(this);
  }

  @override
  void visitDefaultFormalParameter(DefaultFormalParameter node) {
    node.parameter.accept(this);
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    var name = node.name;
    if (name == null || Identifier.isPrivateName(name.name)) {
      return;
    }
    node.extendedType.accept(this);
    node.typeParameters?.accept(this);
    node.members.accept(this);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (node.fields.variables
        .any((field) => !Identifier.isPrivateName(field.name.name))) {
      node.fields.type?.accept(this);
    }
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    if (node.isNamed && Identifier.isPrivateName(node.identifier.name)) {
      return;
    }
    node.type?.accept(this);
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    node.parameters.accept(this);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (Identifier.isPrivateName(node.name.name)) {
      return;
    }
    node.returnType?.accept(this);
    node.functionExpression.typeParameters?.accept(this);
    node.functionExpression.parameters?.accept(this);
  }

  @override
  void visitFunctionTypeAlias(FunctionTypeAlias node) {
    if (Identifier.isPrivateName(node.name.name)) {
      return;
    }
    node.returnType?.accept(this);
    node.typeParameters?.accept(this);
    node.parameters.accept(this);
  }

  @override
  void visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    if (node.isNamed && Identifier.isPrivateName(node.identifier.name)) {
      return;
    }
    node.returnType?.accept(this);
    node.typeParameters?.accept(this);
    node.parameters.accept(this);
  }

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    node.returnType?.accept(this);
    node.typeParameters?.accept(this);
    node.parameters.accept(this);
  }

  @override
  void visitGenericTypeAlias(GenericTypeAlias node) {
    if (Identifier.isPrivateName(node.name.name)) {
      return;
    }
    node.typeParameters?.accept(this);
    node.functionType?.accept(this);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (Identifier.isPrivateName(node.name.name)) {
      return;
    }
    node.returnType?.accept(this);
    node.typeParameters?.accept(this);
    node.parameters?.accept(this);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    if (Identifier.isPrivateName(node.name.name)) {
      return;
    }
    node.onClause?.superclassConstraints.accept(this);
    node.typeParameters?.accept(this);
    node.members.accept(this);
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    var name = node.identifier;
    if (name != null && node.isNamed && Identifier.isPrivateName(name.name)) {
      return;
    }
    node.type?.accept(this);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    if (node.variables.variables
        .any((field) => !Identifier.isPrivateName(field.name.name))) {
      node.variables.type?.accept(this);
    }
  }

  @override
  void visitTypeArgumentList(TypeArgumentList node) {
    node.arguments.accept(this);
  }

  @override
  void visitTypeName(TypeName node) {
    var element = node.name.staticElement;
    if (element != null && isPrivate(element)) {
      rule.reportLint(node.name);
    }
    node.typeArguments?.accept(this);
  }

  @override
  void visitTypeParameter(TypeParameter node) {
    node.bound?.accept(this);
  }

  @override
  void visitTypeParameterList(TypeParameterList node) {
    node.typeParameters.accept(this);
  }

  /// Return `true` if the given [element] is private or is defined in a private
  /// library.
  static bool isPrivate(Element element) {
    var name = element.name;
    return name != null && Identifier.isPrivateName(name);
  }
}

class Visitor extends SimpleAstVisitor {
  LintRule rule;

  Visitor(this.rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    if (!Validator.isPrivate(node.declaredElement!)) {
      var validator = Validator(rule);
      node.declarations.accept(validator);
    }
  }
}
