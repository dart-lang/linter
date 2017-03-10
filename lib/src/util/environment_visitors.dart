// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.util.visitor_with_scope;

import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

class ElementBox implements Nameable {
  Element element;
  ElementBox(this.element);

  @override
  bool hasName(String name) => element.name == name;
}

abstract class LookUpVisitor<T> extends SimpleAstVisitor<T> {
  _MainCallVisitor<T, ElementBox> _mainCallVisitor;
  LookUpVisitor() {
    _mainCallVisitor = new _MainCallVisitor<T, ElementBox>(
        new _IdentifiersScopeVisitor<T>(this));
  }
  AstVisitor<T> getVisitor() => _mainCallVisitor;
  Element lookUp(String name) => _mainCallVisitor.lookUp(name).element;
}

abstract class Nameable {
  bool hasName(String name);
}

abstract class _EnvironmentVisitor<T, E extends Nameable>
    extends RecursiveAstVisitor<T> {
  final AstVisitor<T> baseVisitor;
  final Queue<Queue<E>> environments = new Queue();

  _EnvironmentVisitor(this.baseVisitor);

  E lookUp(String name) {
    if (name == null) {
      throw new ArgumentError.notNull('name');
    }
    for (final environment in environments) {
      for (final element in environment) {
        if (element.hasName(name)) {
          return element;
        }
      }
    }
    return null; // TODO: Return a dummy E
  }

  @override
  T visitAdjacentStrings(AdjacentStrings node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitAdjacentStrings(node);
    super.visitAdjacentStrings(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitAnnotation(Annotation node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitAnnotation(node);
    super.visitAnnotation(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitArgumentList(ArgumentList node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitArgumentList(node);
    super.visitArgumentList(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitAsExpression(AsExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitAsExpression(node);
    super.visitAsExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitAssertStatement(AssertStatement node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitAssertStatement(node);
    super.visitAssertStatement(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitAssignmentExpression(AssignmentExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitAssignmentExpression(node);
    super.visitAssignmentExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitAwaitExpression(AwaitExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitAwaitExpression(node);
    super.visitAwaitExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitBinaryExpression(BinaryExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitBinaryExpression(node);
    super.visitBinaryExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitBlock(Block node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitBlock(node);
    super.visitBlock(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitBlockFunctionBody(BlockFunctionBody node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitBlockFunctionBody(node);
    super.visitBlockFunctionBody(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitBooleanLiteral(BooleanLiteral node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitBooleanLiteral(node);
    super.visitBooleanLiteral(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitBreakStatement(BreakStatement node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitBreakStatement(node);
    super.visitBreakStatement(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitCascadeExpression(CascadeExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitCascadeExpression(node);
    super.visitCascadeExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitCatchClause(CatchClause node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitCatchClause(node);
    super.visitCatchClause(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitClassDeclaration(ClassDeclaration node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitClassDeclaration(node);
    super.visitClassDeclaration(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitClassTypeAlias(ClassTypeAlias node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitClassTypeAlias(node);
    super.visitClassTypeAlias(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitComment(Comment node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitComment(node);
    super.visitComment(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitCommentReference(CommentReference node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitCommentReference(node);
    super.visitCommentReference(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitCompilationUnit(CompilationUnit node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitCompilationUnit(node);
    super.visitCompilationUnit(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitConditionalExpression(ConditionalExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitConditionalExpression(node);
    super.visitConditionalExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitConfiguration(Configuration node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitConfiguration(node);
    super.visitConfiguration(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitConstructorDeclaration(ConstructorDeclaration node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitConstructorDeclaration(node);
    super.visitConstructorDeclaration(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    //_addLocalEnvironment();
    super.visitConstructorFieldInitializer(node);
    T result = baseVisitor.visitConstructorFieldInitializer(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitConstructorName(ConstructorName node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitConstructorName(node);
    super.visitConstructorName(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitContinueStatement(ContinueStatement node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitContinueStatement(node);
    super.visitContinueStatement(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitDeclaredIdentifier(DeclaredIdentifier node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitDeclaredIdentifier(node);
    super.visitDeclaredIdentifier(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitDefaultFormalParameter(DefaultFormalParameter node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitDefaultFormalParameter(node);
    super.visitDefaultFormalParameter(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitDoStatement(DoStatement node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitDoStatement(node);
    super.visitDoStatement(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitDottedName(DottedName node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitDottedName(node);
    super.visitDottedName(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitDoubleLiteral(DoubleLiteral node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitDoubleLiteral(node);
    super.visitDoubleLiteral(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitEmptyFunctionBody(EmptyFunctionBody node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitEmptyFunctionBody(node);
    super.visitEmptyFunctionBody(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitEmptyStatement(EmptyStatement node) {
    //_addLocalEnvironment();
    super.visitEmptyStatement(node);
    T result = baseVisitor.visitEmptyStatement(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitEnumConstantDeclaration(EnumConstantDeclaration node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitEnumConstantDeclaration(node);
    super.visitEnumConstantDeclaration(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitEnumDeclaration(EnumDeclaration node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitEnumDeclaration(node);
    super.visitEnumDeclaration(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitExportDirective(ExportDirective node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitExportDirective(node);
    super.visitExportDirective(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitExpressionFunctionBody(ExpressionFunctionBody node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitExpressionFunctionBody(node);
    super.visitExpressionFunctionBody(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitExpressionStatement(ExpressionStatement node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitExpressionStatement(node);
    super.visitExpressionStatement(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitExtendsClause(ExtendsClause node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitExtendsClause(node);
    super.visitExtendsClause(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitFieldDeclaration(FieldDeclaration node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitFieldDeclaration(node);
    super.visitFieldDeclaration(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitFieldFormalParameter(FieldFormalParameter node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitFieldFormalParameter(node);
    super.visitFieldFormalParameter(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitForEachStatement(ForEachStatement node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitForEachStatement(node);
    super.visitForEachStatement(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitFormalParameterList(FormalParameterList node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitFormalParameterList(node);
    super.visitFormalParameterList(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitForStatement(ForStatement node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitForStatement(node);
    super.visitForStatement(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitFunctionDeclaration(FunctionDeclaration node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitFunctionDeclaration(node);
    super.visitFunctionDeclaration(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitFunctionDeclarationStatement(node);
    super.visitFunctionDeclarationStatement(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitFunctionExpression(FunctionExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitFunctionExpression(node);
    super.visitFunctionExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitFunctionExpressionInvocation(node);
    super.visitFunctionExpressionInvocation(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitFunctionTypeAlias(FunctionTypeAlias node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitFunctionTypeAlias(node);
    super.visitFunctionTypeAlias(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitFunctionTypedFormalParameter(node);
    super.visitFunctionTypedFormalParameter(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitHideCombinator(HideCombinator node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitHideCombinator(node);
    super.visitHideCombinator(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitIfStatement(IfStatement node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitIfStatement(node);
    super.visitIfStatement(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitImplementsClause(ImplementsClause node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitImplementsClause(node);
    super.visitImplementsClause(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitImportDirective(ImportDirective node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitImportDirective(node);
    super.visitImportDirective(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitIndexExpression(IndexExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitIndexExpression(node);
    super.visitIndexExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitInstanceCreationExpression(InstanceCreationExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitInstanceCreationExpression(node);
    super.visitInstanceCreationExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitIntegerLiteral(IntegerLiteral node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitIntegerLiteral(node);
    super.visitIntegerLiteral(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitInterpolationExpression(InterpolationExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitInterpolationExpression(node);
    super.visitInterpolationExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitInterpolationString(InterpolationString node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitInterpolationString(node);
    super.visitInterpolationString(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitIsExpression(IsExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitIsExpression(node);
    super.visitIsExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitLabel(Label node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitLabel(node);
    super.visitLabel(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitLabeledStatement(LabeledStatement node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitLabeledStatement(node);
    super.visitLabeledStatement(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitLibraryDirective(LibraryDirective node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitLibraryDirective(node);
    super.visitLibraryDirective(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitLibraryIdentifier(LibraryIdentifier node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitLibraryIdentifier(node);
    super.visitLibraryIdentifier(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitListLiteral(ListLiteral node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitListLiteral(node);
    super.visitListLiteral(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitMapLiteral(MapLiteral node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitMapLiteral(node);
    super.visitMapLiteral(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitMapLiteralEntry(MapLiteralEntry node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitMapLiteralEntry(node);
    super.visitMapLiteralEntry(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitMethodDeclaration(MethodDeclaration node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitMethodDeclaration(node);
    super.visitMethodDeclaration(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitMethodInvocation(MethodInvocation node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitMethodInvocation(node);
    super.visitMethodInvocation(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitNamedExpression(NamedExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitNamedExpression(node);
    super.visitNamedExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitNativeClause(NativeClause node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitNativeClause(node);
    super.visitNativeClause(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitNativeFunctionBody(NativeFunctionBody node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitNativeFunctionBody(node);
    super.visitNativeFunctionBody(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitNullLiteral(NullLiteral node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitNullLiteral(node);
    super.visitNullLiteral(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitParenthesizedExpression(ParenthesizedExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitParenthesizedExpression(node);
    super.visitParenthesizedExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitPartDirective(PartDirective node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitPartDirective(node);
    super.visitPartDirective(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitPartOfDirective(PartOfDirective node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitPartOfDirective(node);
    super.visitPartOfDirective(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitPostfixExpression(PostfixExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitPostfixExpression(node);
    super.visitPostfixExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitPrefixedIdentifier(PrefixedIdentifier node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitPrefixedIdentifier(node);
    super.visitPrefixedIdentifier(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitPrefixExpression(PrefixExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitPrefixExpression(node);
    super.visitPrefixExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitPropertyAccess(PropertyAccess node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitPropertyAccess(node);
    super.visitPropertyAccess(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitRedirectingConstructorInvocation(
      RedirectingConstructorInvocation node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitRedirectingConstructorInvocation(node);
    super.visitRedirectingConstructorInvocation(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitRethrowExpression(RethrowExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitRethrowExpression(node);
    super.visitRethrowExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitReturnStatement(ReturnStatement node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitReturnStatement(node);
    super.visitReturnStatement(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitScriptTag(ScriptTag node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitScriptTag(node);
    super.visitScriptTag(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitShowCombinator(ShowCombinator node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitShowCombinator(node);
    super.visitShowCombinator(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitSimpleFormalParameter(SimpleFormalParameter node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitSimpleFormalParameter(node);
    super.visitSimpleFormalParameter(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitSimpleIdentifier(SimpleIdentifier node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitSimpleIdentifier(node);
    super.visitSimpleIdentifier(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitSimpleStringLiteral(SimpleStringLiteral node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitSimpleStringLiteral(node);
    super.visitSimpleStringLiteral(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitStringInterpolation(StringInterpolation node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitStringInterpolation(node);
    super.visitStringInterpolation(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitSuperConstructorInvocation(SuperConstructorInvocation node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitSuperConstructorInvocation(node);
    super.visitSuperConstructorInvocation(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitSuperExpression(SuperExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitSuperExpression(node);
    super.visitSuperExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitSwitchCase(SwitchCase node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitSwitchCase(node);
    super.visitSwitchCase(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitSwitchDefault(SwitchDefault node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitSwitchDefault(node);
    super.visitSwitchDefault(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitSwitchStatement(SwitchStatement node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitSwitchStatement(node);
    super.visitSwitchStatement(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitSymbolLiteral(SymbolLiteral node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitSymbolLiteral(node);
    super.visitSymbolLiteral(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitThisExpression(ThisExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitThisExpression(node);
    super.visitThisExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitThrowExpression(ThrowExpression node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitThrowExpression(node);
    super.visitThrowExpression(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitTopLevelVariableDeclaration(node);
    super.visitTopLevelVariableDeclaration(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitTryStatement(TryStatement node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitTryStatement(node);
    super.visitTryStatement(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitTypeArgumentList(TypeArgumentList node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitTypeArgumentList(node);
    super.visitTypeArgumentList(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitTypeName(TypeName node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitTypeName(node);
    super.visitTypeName(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitTypeParameter(TypeParameter node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitTypeParameter(node);
    super.visitTypeParameter(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitTypeParameterList(TypeParameterList node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitTypeParameterList(node);
    super.visitTypeParameterList(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitVariableDeclaration(VariableDeclaration node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitVariableDeclaration(node);
    super.visitVariableDeclaration(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitVariableDeclarationList(VariableDeclarationList node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitVariableDeclarationList(node);
    super.visitVariableDeclarationList(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitVariableDeclarationStatement(node);
    super.visitVariableDeclarationStatement(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitWhileStatement(WhileStatement node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitWhileStatement(node);
    super.visitWhileStatement(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitWithClause(WithClause node) {
    _addLocalEnvironment();
    T result = baseVisitor.visitWithClause(node);
    super.visitWithClause(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitYieldStatement(YieldStatement node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitYieldStatement(node);
    super.visitYieldStatement(node);
    //_removeLocalEnvironment();
    return result;
  }

  void _addElementToEnvironment(E e) {
    if (e != null) {
      environments.first.addFirst(e);
    }
  }

  void _addLocalEnvironment() {
    environments.addFirst(new Queue());
  }

  void _removeLocalEnvironment() {
    environments.removeFirst();
  }
}

class _IdentifiersScopeVisitor<T> extends _EnvironmentVisitor<T, ElementBox> {
  _IdentifiersScopeVisitor(AstVisitor<T> baseVisitor) : super(baseVisitor);

  @override
  T visitClassDeclaration(ClassDeclaration node) {
    _addLocalEnvironment();
    node.members.forEach((e) {
      _addElementToEnvironment(new ElementBox(e.element));
    });
    T result = baseVisitor.visitClassDeclaration(node);
    super.visitClassDeclaration(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitCompilationUnit(CompilationUnit node) {
    _addLocalEnvironment();
    node.declarations.forEach((e) {
      this._addElementToEnvironment(new ElementBox(e.element));
    });
    T result = baseVisitor.visitCompilationUnit(node);
    super.visitCompilationUnit(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitFormalParameterList(FormalParameterList node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitFormalParameterList(node);
    node.parameterElements.forEach((e) {
      this._addElementToEnvironment(new ElementBox(e));
    });
    super.visitFormalParameterList(node);
    //_removeLocalEnvironment();
    return result;
  }

  @override
  T visitFunctionDeclaration(FunctionDeclaration node) {
    // Necessary for local functions
    if (node.parent is FunctionDeclarationStatement) {
      _addElementToEnvironment(new ElementBox(node.element));
    }
    _addLocalEnvironment();
    T result = baseVisitor.visitFunctionDeclaration(node);
    super.visitFunctionDeclaration(node);
    _removeLocalEnvironment();
    return result;
  }

  @override
  T visitVariableDeclaration(VariableDeclaration node) {
    //_addLocalEnvironment();
    T result = baseVisitor.visitVariableDeclaration(node);
    _addElementToEnvironment(new ElementBox(node.element));
    super.visitVariableDeclaration(node);
    //_removeLocalEnvironment();
    return result;
  }
}

class _MainCallVisitor<T, E extends Nameable> extends SimpleAstVisitor<T> {
  _EnvironmentVisitor<T, E> _environmentVisitor;
  _MainCallVisitor(this._environmentVisitor);

  E lookUp(String name) => _environmentVisitor.lookUp(name);

  @override
  visitCompilationUnit(CompilationUnit node) {
    _environmentVisitor.visitCompilationUnit(node);
  }
}
