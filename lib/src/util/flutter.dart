// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

const _STATE_NAME = 'State';
final _frameworkUri = Uri.parse('package:flutter/src/widgets/framework.dart');

/// Return `true` if the given [element] has the Flutter class `State` as
/// a superclass.
bool isState(ClassElement element) =>
    _hasSupertype(element, _frameworkUri, _STATE_NAME);

/// Return `true` if the given [element] has a supertype with the [requiredName]
/// defined in the file with the [requiredUri].
bool _hasSupertype(ClassElement element, Uri requiredUri, String requiredName) {
  if (element == null) {
    return false;
  }
  for (InterfaceType type in element.allSupertypes) {
    if (type.name == requiredName) {
      Uri uri = type.element.source.uri;
      if (uri == requiredUri) {
        return true;
      }
    }
  }
  return false;
}
