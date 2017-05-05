import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

class ElementCollectorVisitor extends RecursiveAstVisitor {
  final elements = new LinkedHashSet<Element>();

  @override
  visitPrefixedIdentifier(PrefixedIdentifier node) {
    elements.add(DartTypeUtilities.getCanonicalElement(node.bestElement));
    super.visitPrefixedIdentifier(node);
  }

  @override
  visitPropertyAccess(PropertyAccess node) {
    elements.add(
        DartTypeUtilities.getCanonicalElement(node.propertyName.bestElement));
    super.visitPropertyAccess(node);
  }

  @override
  visitSimpleIdentifier(SimpleIdentifier node) {
    elements.add(DartTypeUtilities.getCanonicalElement(node.bestElement));
    super.visitSimpleIdentifier(node);
  }
}

class SimpleIdentifierCollectorVisitor extends RecursiveAstVisitor {
  final simpleIdentifiers = new LinkedHashSet<SimpleIdentifier>();

  @override
  visitSimpleIdentifier(SimpleIdentifier node) {
    simpleIdentifiers.add(node);
  }
}
