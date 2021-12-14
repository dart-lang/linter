// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../../analyzer.dart';
import 'conformance_rule.dart';
import 'interop_helpers.dart';
import 'web_bindings.dart';

class _BannedPropertyWriteCode extends SecurityLintCode {
  _BannedPropertyWriteCode(
      {required String name,
      required String problemMessage,
      required String correctionMessage})
      : super(name, problemMessage, correctionMessage: correctionMessage);
}

class BannedPropertyWrite extends ConformanceRule {
  final String? nativeType;
  final String? nativeProperty;
  final String? dartHtmlType;
  final String? dartHtmlProperty;
  BannedPropertyWrite(
      {required String name,
      required String description,
      required String details,
      required this.nativeType,
      required this.nativeProperty})
      : dartHtmlType = null,
        dartHtmlProperty = null,
        super(name: name, description: description, details: details);

  // This constructor is meant specifically to disallow specific `dart:html`
  // APIs that aren't `external`. Using this without a separate rule disallowing
  // the native property you are interested in would be insufficient, as this
  // does not cover the interop case.
  BannedPropertyWrite.withDartHtmlTypes(
      {required String name,
      required String description,
      required String details,
      required this.dartHtmlType,
      required this.dartHtmlProperty})
      : nativeType = null,
        nativeProperty = null,
        super(name: name, description: description, details: details);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _BannedPropertyWriteVisitor(this);
    registry.addCompilationUnit(this, visitor);
    registry.addAssignmentExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _BannedPropertyWriteVisitor extends SimpleAstVisitor<void> {
  final BannedPropertyWrite rule;

  _BannedPropertyWriteVisitor(this.rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    computeHtmlBindings(node.declaredElement?.library);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression expression) {
    var leftHandSide = expression.leftHandSide;
    DartType? dartTargetType;
    String dartProperty;
    if (leftHandSide is PropertyAccess) {
      dartTargetType = leftHandSide.realTarget.staticType;
      dartProperty = leftHandSide.propertyName.name;
    } else if (leftHandSide is PrefixedIdentifier) {
      dartTargetType = leftHandSide.prefix.staticType;
      dartProperty = leftHandSide.identifier.name;
    } else {
      return;
    }

    var dartTargetTypeElement = dartTargetType?.element;

    if (dartTargetType == null || dartTargetTypeElement == null) return;

    var dartHtmlBindingProperty = getWebLibraryMember(
        nativeType: rule.nativeType, nativeMember: rule.nativeProperty);

    var writeElement = expression.writeElement;
    var isExternal = false;
    if (writeElement is PropertyAccessorElement) {
      // Use the variable declaration instead of the synthesized setter.
      if (writeElement.isSynthetic) {
        var variable = writeElement.variable;
        if (variable is FieldElement) isExternal = variable.isExternal;
      } else {
        isExternal = writeElement.isExternal;
      }
    }

    // If there is no `dart:html` binding for the given native type, we can use
    // `@JS` or `@anonymous`. This means dynamic interop is possible.
    var canUseDynamicInterop =
        rule.nativeType != null && !hasDartHtmlBinding(rule.nativeType!);

    // Report a lint if the target type is dynamic and one of the following
    // holds true:
    //
    // 1. The property name matches the `dart:html` declaration name for the
    // given native property.
    // 2. The property name matches the given `dart:html` property.
    // 3. The property name matches the given native property, and the type
    // can be dynamically interop'd.
    if (dartTargetType.isDynamic &&
        (dartProperty == dartHtmlBindingProperty ||
            dartProperty == rule.dartHtmlProperty ||
            canUseDynamicInterop && dartProperty == rule.nativeProperty)) {
      rule.reportLint(expression,
          errorCode: _BannedPropertyWriteCode(
              name: rule.name,
              problemMessage:
                  'This conformance check is being triggered because the '
                  'static type of the target is dynamic.',
              correctionMessage:
                  'Try casting the target to a non-dynamic type.'));
    } else if (dartTargetTypeElement is ClassElement) {
      if (isExternal &&
          dartTargetTypeElement.hasJS &&
          dartProperty == rule.nativeProperty) {
        // Only `@staticInterop` classes can interop the types bound to a
        // `@Native` class. If there is no such binding however, then there
        // needs to be a check for `@JS` and `@anonymous` classes as well.
        if (isStaticInteropType(dartTargetTypeElement)) {
          rule.reportLint(expression,
              errorCode: _BannedPropertyWriteCode(
                  name: rule.name,
                  problemMessage:
                      '@staticInterop types may be used to interface native '
                      'types, so this property write may violate conformance.',
                  correctionMessage:
                      'Avoid using the same name as disallowed properties in '
                      '@staticInterop classes.'));
        } else if (canUseDynamicInterop) {
          rule.reportLint(expression,
              errorCode: _BannedPropertyWriteCode(
                  name: rule.name,
                  problemMessage:
                      'Since there is no `dart:html` class for this native '
                      'type, non-`@staticInterop` `package:js` classes may be '
                      'used to interop with it, so this property may violate '
                      'conformance.',
                  correctionMessage: 'Avoid using this property name in '
                      'all `package:js` classes.'));
        }
      } else if (fromDartHtml(dartTargetTypeElement)) {
        var errorCode = _BannedPropertyWriteCode(
            name: rule.name,
            problemMessage: 'Disallowed `dart:html` property is being used.',
            correctionMessage: 'Avoid using it.');
        // If we only care about Dart types, we don't need to do any further
        // checks.
        var dartTypeName = dartTargetTypeElement.name;
        if (rule.dartHtmlType != null && rule.dartHtmlProperty != null) {
          if (dartTypeName == rule.dartHtmlType &&
              dartProperty == rule.dartHtmlProperty) {
            rule.reportLint(expression, errorCode: errorCode);
          }
          return;
        }

        // Check that it is a `@Native` class.
        var nativeTypes = getBoundNativeTypes(dartType: dartTypeName);
        if (nativeTypes == null) return;

        var nativePropertyName = getNativePropertyBinding(
            dartType: dartTypeName, dartMember: dartProperty);
        if (isExternal &&
            nativeTypes.contains(rule.nativeType) &&
            nativePropertyName == rule.nativeProperty) {
          rule.reportLint(expression, errorCode: errorCode);
        }
      }
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!isJsUtilSetProperty(node)) return;

    var targetType = node.argumentList.arguments[0].staticType;
    var targetTypeElement = targetType?.element;

    if (targetType == null || targetTypeElement == null) return;

    var setPropertyName = node.argumentList.arguments[1];
    if (setPropertyName is! StringLiteral ||
        setPropertyName.stringValue != rule.nativeProperty) return;

    if (targetType.isDartCoreObject) {
      rule.reportLint(node,
          errorCode: _BannedPropertyWriteCode(
              name: rule.name,
              problemMessage:
                  'This conformance check is being triggered because the '
                  'static type of the target is Object.',
              correctionMessage:
                  'Try casting the target to a non-Object type.'));
    } else if (targetTypeElement is ClassElement) {
      if (isNativeInteropType(targetTypeElement, rule.nativeType)) {
        rule.reportLint(node,
            errorCode: _BannedPropertyWriteCode(
                name: rule.name,
                problemMessage:
                    "The target object's type can be used to interface native "
                    'types, so this call to `setProperty` may violate '
                    'conformance.',
                correctionMessage: 'Avoid using this property name in a '
                    '`setProperty` call.'));
      } else if (fromDartHtml(targetTypeElement) &&
          (getBoundNativeTypes(dartType: targetTypeElement.name)
                  ?.contains(rule.nativeType) ??
              false)) {
        rule.reportLint(node,
            errorCode: _BannedPropertyWriteCode(
                name: rule.name,
                problemMessage:
                    'Disallowed `dart:html` property is being used in this '
                    '`setProperty` call.',
                correctionMessage:
                    "Don't use `setProperty` on this `dart:html` class with "
                    'this property name.'));
      }
    }
  }
}
