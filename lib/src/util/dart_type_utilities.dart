// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/type.dart'; // ignore: implementation_imports

import '../analyzer.dart';
import '../ast.dart';
import '../extensions.dart';

typedef AstNodePredicate = bool Function(AstNode node);

/// Returns whether the canonical elements of [element1] and [element2] are
/// equal.
bool canonicalElementsAreEqual(Element? element1, Element? element2) =>
    element1?.canonicalElement == element2?.canonicalElement;

/// Returns whether the canonical elements from two nodes are equal.
///
/// As in, [AstNodeExtension.canonicalElement], the two nodes must be
/// [Expression]s in order to be compared (otherwise `false` is returned).
///
/// The two nodes must both be a [SimpleIdentifier], [PrefixedIdentifier], or
/// [PropertyAccess] (otherwise `false` is returned).
///
/// If the two nodes are PrefixedIdentifiers, or PropertyAccess nodes, then
/// `true` is returned only if their canonical elements are equal, in
/// addition to their prefixes' and targets' (respectfully) canonical
/// elements.
///
/// There is an inherent assumption about pure getters. For example:
///
///     A a1 = ...
///     A a2 = ...
///     a1.b.c; // statement 1
///     a2.b.c; // statement 2
///     a1.b.c; // statement 3
///
/// The canonical elements from statements 1 and 2 are different, because a1
/// is not the same element as a2.  The canonical elements from statements 1
/// and 3 are considered to be equal, even though `A.b` may have side effects
/// which alter the returned value.
bool canonicalElementsFromIdentifiersAreEqual(
    Expression? rawExpression1, Expression? rawExpression2) {
  if (rawExpression1 == null || rawExpression2 == null) return false;

  var expression1 = rawExpression1.unParenthesized;
  var expression2 = rawExpression2.unParenthesized;

  if (expression1 is SimpleIdentifier) {
    return expression2 is SimpleIdentifier &&
        canonicalElementsAreEqual(getWriteOrReadElement(expression1),
            getWriteOrReadElement(expression2));
  }

  if (expression1 is PrefixedIdentifier) {
    return expression2 is PrefixedIdentifier &&
        canonicalElementsAreEqual(expression1.prefix.staticElement,
            expression2.prefix.staticElement) &&
        canonicalElementsAreEqual(getWriteOrReadElement(expression1.identifier),
            getWriteOrReadElement(expression2.identifier));
  }

  if (expression1 is PropertyAccess && expression2 is PropertyAccess) {
    var target1 = expression1.target;
    var target2 = expression2.target;
    return canonicalElementsFromIdentifiersAreEqual(target1, target2) &&
        canonicalElementsAreEqual(
            getWriteOrReadElement(expression1.propertyName),
            getWriteOrReadElement(expression2.propertyName));
  }

  return false;
}

class DartTypeUtilities {
  @Deprecated('Replace with type.extendsClass')
  static bool extendsClass(
          DartType? type, String? className, String? library) =>
      type.extendsClass(className, library!);

  @Deprecated('Replace with `rawNode.canonicalElement`')
  static Element? getCanonicalElementFromIdentifier(AstNode? rawNode) =>
      rawNode.canonicalElement;

  static bool hasInheritedMethod(MethodDeclaration node) =>
      lookUpInheritedMethod(node) != null;

  static bool implementsAnyInterface(
      DartType type, Iterable<InterfaceTypeDefinition> definitions) {
    bool isAnyInterface(InterfaceType i) =>
        definitions.any((d) => isInterface(i, d.name, d.library));

    if (type is InterfaceType) {
      var element = type.element2;
      return isAnyInterface(type) ||
          !element.isSynthetic && element.allSupertypes.any(isAnyInterface);
    } else {
      return false;
    }
  }

  static bool implementsInterface(
      DartType? type, String interface, String library) {
    if (type is! InterfaceType) {
      return false;
    }
    var interfaceType = type;
    bool predicate(InterfaceType i) => isInterface(i, interface, library);
    var element = interfaceType.element2;
    return predicate(interfaceType) ||
        !element.isSynthetic && element.allSupertypes.any(predicate);
  }

  /// todo (pq): unify and  `isInterface` into a shared method: `isInterfaceType`
  static bool isClass(DartType? type, String? className, String? library) =>
      type is InterfaceType &&
      type.element2.name == className &&
      type.element2.library.name == library;

  /// todo (pq): unify and  `isInterface` into a shared method: `isInterfaceType`
  static bool isMixin(DartType? type, String? className, String? library) =>
      type is InterfaceType &&
      type.element2.name == className &&
      type.element2.library.name == library;

  static bool isConstructorElement(ConstructorElement? element,
          {required String uriStr,
          required String className,
          required String constructorName}) =>
      element != null &&
      element.library.name == uriStr &&
      element.enclosingElement3.name == className &&
      element.name == constructorName;

  static bool isInterface(
          InterfaceType type, String interface, String library) =>
      type.element2.name == interface && type.element2.library.name == library;

  static bool isNonNullable(LinterContext context, DartType? type) =>
      type != null && context.typeSystem.isNonNullable(type);

  @Deprecated('Replace with `expression.isNullLiteral`')
  static bool isNullLiteral(Expression? expression) => expression.isNullLiteral;

  static PropertyAccessorElement? lookUpGetter(MethodDeclaration node) {
    var declaredElement = node.declaredElement;
    if (declaredElement == null) {
      return null;
    }
    var parent = declaredElement.enclosingElement3;
    if (parent is ClassElement) {
      return parent.lookUpGetter(node.name2.lexeme, declaredElement.library);
    }
    if (parent is ExtensionElement) {
      return parent.getGetter(node.name2.lexeme);
    }
    return null;
  }

  static PropertyAccessorElement? lookUpInheritedConcreteGetter(
      MethodDeclaration node) {
    var declaredElement = node.declaredElement;
    if (declaredElement == null) {
      return null;
    }
    var parent = declaredElement.enclosingElement3;
    if (parent is ClassElement) {
      return parent.lookUpInheritedConcreteGetter(
          node.name2.lexeme, declaredElement.library);
    }
    // Extensions don't inherit.
    return null;
  }

  static MethodElement? lookUpInheritedConcreteMethod(MethodDeclaration node) {
    var declaredElement = node.declaredElement;
    if (declaredElement != null) {
      var parent = declaredElement.enclosingElement3;
      if (parent is ClassElement) {
        return parent.lookUpInheritedConcreteMethod(
            node.name2.lexeme, declaredElement.library);
      }
    }
    // Extensions don't inherit.
    return null;
  }

  static PropertyAccessorElement? lookUpInheritedConcreteSetter(
      MethodDeclaration node) {
    var declaredElement = node.declaredElement;
    if (declaredElement != null) {
      var parent = declaredElement.enclosingElement3;
      if (parent is ClassElement) {
        return parent.lookUpInheritedConcreteSetter(
            node.name2.lexeme, declaredElement.library);
      }
    }
    // Extensions don't inherit.
    return null;
  }

  static MethodElement? lookUpInheritedMethod(MethodDeclaration node) {
    var declaredElement = node.declaredElement;
    if (declaredElement != null) {
      var parent = declaredElement.enclosingElement3;
      if (parent is ClassElement) {
        return parent.lookUpInheritedMethod(
            node.name2.lexeme, declaredElement.library);
      }
    }
    return null;
  }

  static PropertyAccessorElement? lookUpSetter(MethodDeclaration node) {
    var declaredElement = node.declaredElement;
    if (declaredElement != null) {
      var parent = declaredElement.enclosingElement3;
      if (parent is ClassElement) {
        return parent.lookUpSetter(node.name2.lexeme, declaredElement.library);
      }
      if (parent is ExtensionElement) {
        return parent.getSetter(node.name2.lexeme);
      }
    }
    return null;
  }

  static bool matchesArgumentsWithParameters(
      NodeList<Expression> arguments, NodeList<FormalParameter> parameters) {
    var namedParameters = <String, Element?>{};
    var namedArguments = <String, Element>{};
    var positionalParameters = <Element?>[];
    var positionalArguments = <Element>[];
    for (var parameter in parameters) {
      var identifier = parameter.name;
      if (identifier != null) {
        if (parameter.isNamed) {
          namedParameters[identifier.lexeme] = parameter.declaredElement;
        } else {
          positionalParameters.add(parameter.declaredElement);
        }
      }
    }
    for (var argument in arguments) {
      if (argument is NamedExpression) {
        var element = argument.expression.canonicalElement;
        if (element == null) {
          return false;
        }
        namedArguments[argument.name.label.name] = element;
      } else {
        var element = argument.canonicalElement;
        if (element == null) {
          return false;
        }
        positionalArguments.add(element);
      }
    }
    if (positionalParameters.length != positionalArguments.length ||
        namedParameters.keys.length != namedArguments.keys.length) {
      return false;
    }
    for (var i = 0; i < positionalArguments.length; i++) {
      if (positionalArguments[i] != positionalParameters[i]) {
        return false;
      }
    }

    for (var key in namedParameters.keys) {
      if (namedParameters[key] != namedArguments[key]) {
        return false;
      }
    }

    return true;
  }

  /// Builds the list resulting from traversing the node in DFS and does not
  /// include the node itself, it excludes the nodes for which the exclusion
  /// predicate returns true, if not provided, all is included.
  static Iterable<AstNode> traverseNodesInDFS(AstNode node,
      {AstNodePredicate? excludeCriteria}) {
    var nodes = <AstNode>{};
    void recursiveCall(node) {
      if (node is AstNode &&
          (excludeCriteria == null || !excludeCriteria(node))) {
        nodes.add(node);
        node.childEntities.forEach(recursiveCall);
      }
    }

    node.childEntities.forEach(recursiveCall);
    return nodes;
  }

  /// Returns whether [leftType] and [rightType] are _definitely_ unrelated.
  ///
  /// For the purposes of this function, here are some "relation" rules:
  /// * `dynamic` and `Null` are considered related to any other type.
  /// * Two types which are equal modulo nullability are considered related,
  ///   e.g. `int` and `int`, `String` and `String?`, `List<String>` and
  ///   `List<String>`, `List<T>` and `List<T>`, and type variables `A` and `A`.
  /// * Two types such that one is a subtype of the other, modulo nullability,
  ///   such as `List<dynamic>` and `Iterable<dynamic>`, and type variables `A`
  ///   and `B` where `A extends B`, are considered related.
  /// * Two interface types:
  ///   * are related if they represent the same class, modulo type arguments,
  ///     modulo nullability, and each of their pair-wise type arguments are
  ///     related, e.g. `List<dynamic>` and `List<int>`, and `Future<T>` and
  ///     `Future<S>` where `S extends T`.
  ///   * are unrelated if [leftType]'s supertype is [Object].
  ///   * are related if their supertypes are equal, e.g. `List<dynamic>` and
  ///     `Set<dynamic>`.
  /// * Two type variables are related if their bounds are related.
  /// * Otherwise, the types are related.
  // TODO(srawlins): typedefs and functions in general.
  static bool unrelatedTypes(
      TypeSystem typeSystem, DartType? leftType, DartType? rightType) {
    // If we don't have enough information, or can't really compare the types,
    // return false as they _might_ be related.
    if (leftType == null ||
        leftType.isBottom ||
        leftType.isDynamic ||
        rightType == null ||
        rightType.isBottom ||
        rightType.isDynamic) {
      return false;
    }
    var promotedLeftType = typeSystem.promoteToNonNull(leftType);
    var promotedRightType = typeSystem.promoteToNonNull(rightType);
    if (promotedLeftType == promotedRightType ||
        typeSystem.isSubtypeOf(promotedLeftType, promotedRightType) ||
        typeSystem.isSubtypeOf(promotedRightType, promotedLeftType)) {
      return false;
    }
    if (promotedLeftType is InterfaceType &&
        promotedRightType is InterfaceType) {
      // In this case, [leftElement] and [rightElement] each represent
      // the same class, like `int`, or `Iterable<String>`.
      var leftElement = promotedLeftType.element2;
      var rightElement = promotedRightType.element2;
      if (leftElement == rightElement) {
        // In this case, [leftElement] and [rightElement] represent the same
        // class, modulo generics, e.g. `List<int>` and `List<dynamic>`. Now we
        // need to check type arguments.
        var leftTypeArguments = promotedLeftType.typeArguments;
        var rightTypeArguments = promotedRightType.typeArguments;
        if (leftTypeArguments.length != rightTypeArguments.length) {
          // I cannot think of how we would enter this block, but it guards
          // against RangeError below.
          return false;
        }
        for (var i = 0; i < leftTypeArguments.length; i++) {
          // If any of the pair-wise type arguments are unrelated, then
          // [leftType] and [rightType] are unrelated.
          if (unrelatedTypes(
              typeSystem, leftTypeArguments[i], rightTypeArguments[i])) {
            return true;
          }
        }
        // Otherwise, they might be related.
        return false;
      } else {
        return (leftElement.supertype?.isDartCoreObject ?? false) ||
            leftElement.supertype != rightElement.supertype;
      }
    } else if (promotedLeftType is TypeParameterType &&
        promotedRightType is TypeParameterType) {
      return unrelatedTypes(typeSystem, promotedLeftType.element.bound,
          promotedRightType.element.bound);
    } else if (promotedLeftType is FunctionType) {
      if (_isFunctionTypeUnrelatedToType(promotedLeftType, promotedRightType)) {
        return true;
      }
    } else if (promotedRightType is FunctionType) {
      if (_isFunctionTypeUnrelatedToType(promotedRightType, promotedLeftType)) {
        return true;
      }
    }
    return false;
  }

  static bool _isFunctionTypeUnrelatedToType(
      FunctionType type1, DartType type2) {
    if (type2 is FunctionType) {
      return false;
    }
    if (type2 is InterfaceType) {
      var element2 = type2.element2;
      if (element2 is ClassElement &&
          element2.lookUpConcreteMethod('call', element2.library) != null) {
        return false;
      }
    }
    return true;
  }
}

class InterfaceTypeDefinition {
  final String name;
  final String library;

  InterfaceTypeDefinition(this.name, this.library);

  @override
  int get hashCode => name.hashCode ^ library.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is InterfaceTypeDefinition &&
        name == other.name &&
        library == other.library;
  }
}

extension DartTypeExtensions on DartType {
  /// Returns the type which should be used when conducting "interface checks"
  /// on `this`.
  ///
  /// If `this` is a type variable, then the type-for-interface-check of its
  /// promoted bound or bound is returned. Otherwise, `this` is returned.
  // TODO(srawlins): Move to extensions.dart.
  DartType get typeForInterfaceCheck {
    if (this is TypeParameterType) {
      if (this is TypeParameterTypeImpl) {
        var promotedType = (this as TypeParameterTypeImpl).promotedBound;
        if (promotedType != null) {
          return promotedType.typeForInterfaceCheck;
        }
      }
      return (this as TypeParameterType).bound.typeForInterfaceCheck;
    } else {
      return this;
    }
  }
}
