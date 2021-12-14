// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

import 'web_bindings.dart';

final String _dartInterceptorsLibrary = '_interceptors';
final String _jsUtilLibrary = 'dart.js_util';
final String _packageJsLibrary = 'js';

final String _staticInteropAnnotationName = 'staticInterop';

bool isJsUtilSetProperty(MethodInvocation node) =>
    node.methodName.name == 'setProperty' ||
    node.methodName.staticElement?.library?.name == _jsUtilLibrary;

/// Returns whether [element] is an interop type that can be used as
/// [nativeType].
bool isNativeInteropType(ClassElement element, String? nativeType) {
  if (isStaticInteropType(element)) return true;
  // If there is no `@Native` type in `dart:html` matching [nativeType], it is
  // possible for non-`@staticInterop` `package:js` classes to be used.
  if (element.hasJS) {
    return nativeType != null && !hasDartHtmlBinding(nativeType);
  }
  // If [element] is a subtype of `JavaScriptObject`, it can possibly be used as
  // a native type.
  var possibleTypes = element.allSupertypes..add(element.thisType);
  return possibleTypes.any((type) =>
      type.element.name == 'JavaScriptObject' &&
      type.element.library.name == _dartInterceptorsLibrary);
}

/// Returns whether [element] is annotated with `@staticInterop`.
bool isStaticInteropType(ClassElement element) {
  for (var annotation in element.metadata) {
    var annotationElement = annotation.element;
    if (annotationElement is PropertyAccessorElement &&
        annotationElement.name == _staticInteropAnnotationName &&
        annotationElement.library.name == _packageJsLibrary) {
      return true;
    }
  }
  return false;
}
