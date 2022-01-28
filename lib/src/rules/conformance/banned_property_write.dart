// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../../analyzer.dart';
import 'conformance_rule.dart';
import 'descriptors.dart';
import 'interop_helpers.dart';
import 'web_bindings.dart';

class _BannedPropertyWriteCode extends SecurityLintCode {
  _BannedPropertyWriteCode(
      {required String name,
      required String problemMessage,
      required String correctionMessage})
      : super(name, problemMessage, correctionMessage: correctionMessage);
}

/// Lint rule that disallows a property write for either the given native
/// type-property pair or the given `dart:html` type-property pair.
class BannedPropertyWrite extends ConformanceRule {
  final MemberDescriptor descriptor;
  BannedPropertyWrite(
      {required String name,
      required String description,
      required String details,
      required String nativeType,
      required String nativeProperty})
      : descriptor =
            NativeMemberDescriptor(type: nativeType, member: nativeProperty),
        super(name: name, description: description, details: details);

  // This constructor is meant specifically to disallow specific `dart:html`
  // APIs that aren't `external`. Using this without a separate rule disallowing
  // the native property you are interested in would be insufficient, as this
  // does not cover the interop case.
  BannedPropertyWrite.withDartHtmlTypes(
      {required String name,
      required String description,
      required String details,
      required String dartHtmlType,
      required String dartHtmlProperty})
      : descriptor = DartHtmlMemberDescriptor(
            type: dartHtmlType, member: dartHtmlProperty),
        super(name: name, description: description, details: details);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _BannedPropertyWriteVisitor(this);
    registry.addAssignmentExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _BannedPropertyWriteVisitor extends SimpleAstVisitor<void> {
  final BannedPropertyWrite _rule;
  static final DartHtmlBindings _bindings = DartHtmlBindings();

  _BannedPropertyWriteVisitor(this._rule);

  @override
  void visitAssignmentExpression(AssignmentExpression expression) {
    _bindings.cacheLibrary(expression);

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

    if (dartProperty.isEmpty ||
        dartTargetType == null ||
        dartTargetTypeElement == null) return;

    MemberDescriptor descriptor = _rule.descriptor;

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
    var canUseDynamicInterop = !_bindings.hasDartHtmlBinding(descriptor);

    // Report a lint if the target type is dynamic and one of the following
    // holds true:
    //
    // 1. The property name matches the `dart:html` declaration name for the
    // given native property.
    // 2. The property name matches the given `dart:html` property.
    // 3. The property name matches the given native property, and the type
    // can be dynamically interop'd.
    if (dartTargetType.isDynamic &&
        (dartProperty == _bindings.getWebLibraryMember(descriptor) ||
            (descriptor.isDartHtml && dartProperty == descriptor.member) ||
            (descriptor.isNative &&
                canUseDynamicInterop &&
                dartProperty == descriptor.member))) {
      _rule.reportLint(expression,
          errorCode: _BannedPropertyWriteCode(
              name: _rule.name,
              problemMessage:
                  'This conformance check is being triggered because the '
                  'static type of the target is dynamic.',
              correctionMessage:
                  'Try casting the target to a non-dynamic type.'));
    } else if (dartTargetTypeElement is ClassElement) {
      if (isExternal &&
          dartTargetTypeElement.hasJS &&
          descriptor.isNative &&
          dartProperty == descriptor.member) {
        // Only `@staticInterop` classes can interop the types bound to a
        // `@Native` class. If there is no such binding however, then there
        // needs to be a check for `@JS` and `@anonymous` classes as well.
        if (isStaticInteropType(dartTargetTypeElement)) {
          _rule.reportLint(expression,
              errorCode: _BannedPropertyWriteCode(
                  name: _rule.name,
                  problemMessage:
                      '@staticInterop types may be used to interface native '
                      'types, so this property write may violate conformance.',
                  correctionMessage:
                      'Avoid using the same name as disallowed properties in '
                      '@staticInterop classes.'));
        } else if (canUseDynamicInterop) {
          _rule.reportLint(expression,
              errorCode: _BannedPropertyWriteCode(
                  name: _rule.name,
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
            name: _rule.name,
            problemMessage: 'Disallowed `dart:html` property is being used.',
            correctionMessage: 'Avoid using it.');
        // If we only care about `dart:html` types, we don't need to do any
        // further checks.
        var dartTypeName = dartTargetTypeElement.name;
        if (descriptor.isDartHtml) {
          if (dartTypeName == descriptor.type &&
              dartProperty == descriptor.member) {
            _rule.reportLint(expression, errorCode: errorCode);
          }
          return;
        }

        // Check that the target is a `@Native` class.
        var assignmentDescriptor =
            DartHtmlMemberDescriptor(type: dartTypeName, member: dartProperty);
        var nativeTypes = _bindings.getBoundNativeTypes(assignmentDescriptor);
        if (nativeTypes.isEmpty) return;

        // Check whether there's a binding for the property, and that the
        // binding matches the rule.
        var nativePropertyName =
            _bindings.getNativeMemberBinding(assignmentDescriptor);
        if (isExternal &&
            nativeTypes.contains(descriptor.type) &&
            nativePropertyName == descriptor.member) {
          _rule.reportLint(expression, errorCode: errorCode);
        }
      }
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!isJsUtilSetProperty(node)) return;

    _bindings.cacheLibrary(node);

    var targetType = node.argumentList.arguments[0].staticType;
    var targetTypeElement = targetType?.element;

    if (targetType == null || targetTypeElement == null) return;

    // Nothing to check if the rule isn't concerned about the native property.
    if (!_rule.descriptor.isNative) return;
    var descriptor = _rule.descriptor as NativeMemberDescriptor;

    var setPropertyName = node.argumentList.arguments[1];
    if (setPropertyName is! StringLiteral ||
        setPropertyName.stringValue != descriptor.member) return;

    if (targetType.isDartCoreObject) {
      _rule.reportLint(node,
          errorCode: _BannedPropertyWriteCode(
              name: _rule.name,
              problemMessage:
                  'This conformance check is being triggered because the '
                  'static type of the target is Object.',
              correctionMessage:
                  'Try casting the target to a non-Object type.'));
    } else if (targetTypeElement is ClassElement) {
      if (isNativeInteropType(
          element: targetTypeElement,
          bindings: _bindings,
          descriptor: descriptor)) {
        _rule.reportLint(node,
            errorCode: _BannedPropertyWriteCode(
                name: _rule.name,
                problemMessage:
                    "The target object's type can be used to interface native "
                    'types, so this call to `setProperty` may violate '
                    'conformance.',
                correctionMessage: 'Avoid using this property name in a '
                    '`setProperty` call.'));
      } else if (fromDartHtml(targetTypeElement) &&
          _bindings.getBoundNativeTypes(descriptor).contains(descriptor.type)) {
        _rule.reportLint(node,
            errorCode: _BannedPropertyWriteCode(
                name: _rule.name,
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
