// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:collection/collection.dart' show IterableExtension;

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';

/// Base class for visitor used in rules where we want to lint about invoking
/// methods on generic classes where the type of the singular argument is
/// unrelated to the singular type argument of the class. Extending this
/// visitor is as simple as knowing the methods, classes and libraries that
/// uniquely define the target, i.e. implement only [methods].
abstract class UnrelatedTypesProcessors extends SimpleAstVisitor<void> {
  final LintRule rule;
  final TypeSystem typeSystem;
  final TypeProvider typeProvider;

  UnrelatedTypesProcessors(this.rule, this.typeSystem, this.typeProvider);

  /// The method definitions which this [UnrelatedTypesProcessors] is concerned
  /// with.
  List<MethodDefinition> get methods;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.argumentList.arguments.length != 1) {
      return;
    }

    var methodDefinition = _matchingMethod(node);
    if (methodDefinition == null) {
      return;
    }

    // At this point, we know that [node] is an invocation of a method which
    // has the same name as the method that this [UnrelatedTypesProcessors] is
    // concerned with, and that the method call has a single argument.
    //
    // We've completed the "cheap" checks, and must now continue with the
    // arduous task of determining whether the method target implements
    // [definition].

    DartType? targetType;
    var target = node.realTarget;

    if (target != null) {
      targetType = target.staticType;
    } else {
      for (AstNode? parent = node; parent != null; parent = parent.parent) {
        if (parent is ClassDeclaration) {
          targetType = parent.declaredElement?.thisType;
          break;
        } else if (parent is MixinDeclaration) {
          targetType = parent.declaredElement?.thisType;
          break;
        } else if (parent is EnumDeclaration) {
          targetType = parent.declaredElement?.thisType;
          break;
        } else if (parent is ExtensionDeclaration) {
          targetType = parent.extendedType.type;
          break;
        }
        // TODO(srawlins): Extension? Enum?
      }
    }

    if (targetType is! InterfaceType) {
      return;
    }

    var collectionType = targetType.asInstanceOf(methodDefinition.element);

    if (collectionType == null) {
      return;
    }

    // Finally, determine whether the type of the argument is related to the
    // type of the method target.
    var argumentType = node.argumentList.arguments.first.staticType;

    switch (methodDefinition.expectedArgumentKind) {
      case ExpectedArgumentKind.assignableToCollectionTypeArgument:
        var typeArgument =
            collectionType.typeArguments[methodDefinition.typeArgumentIndex];
        if (typesAreUnrelated(typeSystem, argumentType, typeArgument)) {
          rule.reportLint(node, arguments: [
            typeArgument.getDisplayString(withNullability: true)
          ]);
        }
        break;

      case ExpectedArgumentKind.assignableToCollection:
        if (argumentType != null &&
            typeSystem.isAssignableTo(argumentType, collectionType)) {
          rule.reportLint(node, arguments: [
            collectionType.getDisplayString(withNullability: true)
          ]);
        }
    }
  }

  MethodDefinition? _matchingMethod(MethodInvocation node) => methods
      .firstWhereOrNull((method) => node.methodName.name == method.methodName);
}

/// A definition of a method and the expected characteristics of the first
/// argument to any invocation.
class MethodDefinition {
  /// The element on which this method is declared.
  final ClassElement element;

  final String methodName;

  /// The index of the type argument which the method argument should match.
  final int typeArgumentIndex;

  final ExpectedArgumentKind expectedArgumentKind;

  const MethodDefinition(
    this.element,
    this.methodName,
    this.expectedArgumentKind, {
    this.typeArgumentIndex = 0,
  });
}

/// The kind of the expected argument.
enum ExpectedArgumentKind {
  /// An argument is expected to be assignable to a type argument on the
  /// collection type.
  assignableToCollectionTypeArgument,

  /// An argument is expected to be assignable to the collection type.
  assignableToCollection,
}
