// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Test that properties and class names that are renamed from their `@Native`
// equivalents are still checked.

@JS()
library disallow_set_htmlinputelement_webkitdirectory;

import 'dart:html';
import 'dart:js_util';
import 'package:js/js.dart';

@JS()
@staticInterop
class HTMLInputElementWithSetter {
  external HTMLInputElementWithSetter();
}

extension HTMLInputElementWithSetterExtension on HTMLInputElementWithSetter {
  external set webkitdirectory(bool val);
}

@JS()
@staticInterop
class HTMLInputElementWithVar {
  external HTMLInputElementWithVar();
}

extension HTMLInputElementWithVarExtension on HTMLInputElementWithVar {
  external bool webkitdirectory;
}

@JS()
@staticInterop
class HTMLInputElementWithNonExternal {
  external HTMLInputElementWithNonExternal();
}

extension HTMLInputElementWithNonExternalExtension
    on HTMLInputElementWithNonExternal {
  set webkitdirectory(bool val) {}
  set webkitdirectoryWithJsUtil(bool val) =>
      setProperty<bool>(this, 'webkitdirectory', val); // LINT
}

void main() {
  var webkitdirectory = true;
  // We don't need a real HTMLInputElement here for static checks.
  InputElement inputElement = 0 as InputElement;

  inputElement.directory = webkitdirectory; // LINT
  (inputElement as dynamic).directory = webkitdirectory; // LINT

  var extSetter = HTMLInputElementWithSetter();
  extSetter.webkitdirectory = webkitdirectory; // LINT

  var extVar = HTMLInputElementWithVar();
  extVar.webkitdirectory = webkitdirectory; // LINT

  var nonExt = HTMLInputElementWithNonExternal();
  nonExt.webkitdirectory = webkitdirectory;

  setProperty(extSetter, 'webkitdirectory', webkitdirectory); // LINT
  setProperty(inputElement, 'webkitdirectory', webkitdirectory); // LINT
  Object inputElementObject = inputElement;
  setProperty(inputElementObject, 'webkitdirectory', webkitdirectory); // LINT
}
