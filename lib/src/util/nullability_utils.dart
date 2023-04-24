// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';

/// Return `true` if the expression is null aware, or if one of its recursive
/// targets is null aware.
bool containsNullAwareInvocationInChain(AstNode? node) {
  if (node is PropertyAccess) {
    if (node.isNullAware) return true;
    return containsNullAwareInvocationInChain(node.target);
  } else if (node is MethodInvocation) {
    if (node.isNullAware) return true;
    return containsNullAwareInvocationInChain(node.target);
  } else if (node is IndexExpression) {
    if (node.isNullAware) return true;
    return containsNullAwareInvocationInChain(node.target);
  }
  return false;
}
