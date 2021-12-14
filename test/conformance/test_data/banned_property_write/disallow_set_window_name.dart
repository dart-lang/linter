// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Test that properties that are disallowed from being set are checked using the
// native type and property.

@JS()
library disallow_set_window_name;

import 'dart:html';
import 'dart:js_util';
import 'package:js/js.dart';

@JS()
@staticInterop
class WindowWithSetter {
  external WindowWithSetter();
}

extension WindowWithSetterExtension on WindowWithSetter {
  external set name(String val);
}

@JS()
@staticInterop
class WindowWithVar {
  external WindowWithVar();
}

extension WindowWithVarExtension on WindowWithVar {
  external String name;
}

@JS()
@staticInterop
class WindowWithNonExternal {
  external WindowWithNonExternal();
}

extension WindowWithNonExternalExtension on WindowWithNonExternal {
  set name(String val) {}
  set nameWthJsUtil(String val) =>
      setProperty<String>(this, 'name', val); // LINT
}

void main() {
  var name = 'name';

  window.name = name; // LINT
  (window as dynamic).name = name; // LINT

  var extSetter = WindowWithSetter();
  extSetter.name = name; // LINT

  var extVar = WindowWithVar();
  extVar.name = name; // LINT

  var nonExt = WindowWithNonExternal();
  nonExt.name = name;

  setProperty(extSetter, 'name', name); // LINT
  setProperty(window, 'name', name); // LINT
  Object windowObj = window;
  setProperty(windowObj, 'name', name); // LINT
}
