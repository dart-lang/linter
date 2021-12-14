// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Test that Dart-specific properties are checked.

@JS()
library disallow_set_htmldocument_title;

import 'dart:html';
import 'dart:js_util';
import 'package:js/js.dart';

@JS()
@staticInterop
class HtmlDocumentWithSetter {
  external HtmlDocumentWithSetter();
}

extension HtmlDocumentWithSetterExtension on HtmlDocumentWithSetter {
  external set title(String val);
}

@JS()
@staticInterop
class HtmlDocumentWithVar {
  external HtmlDocumentWithVar();
}

extension HtmlDocumentWithVarExtension on HtmlDocumentWithVar {
  external String title;
}

@JS()
@staticInterop
class HtmlDocumentWithNonExternal {
  external HtmlDocumentWithNonExternal();
}

extension HtmlDocumentWithNonExternalExtension on HtmlDocumentWithNonExternal {
  set title(String val) {}
  set titleWithJsUtil(String val) => setProperty<String>(this, 'title', val);
}

void main() {
  var title = 'title';
  // We don't need a real HtmlDocument here for static checks.
  HtmlDocument htmlDocument = 0 as HtmlDocument;

  htmlDocument.title = title; // LINT
  (htmlDocument as dynamic).title = title; // LINT

  var nonExt = HtmlDocumentWithNonExternal();
  nonExt.title = title;

  // Note that the following do not trigger any lints, because we're using the
  // Dart declaration for the rule. Only calls to that `dart:html` declaration
  // or dynamic calls with the same property name are checked.
  var extSetter = HtmlDocumentWithSetter();
  extSetter.title = title;

  var extVar = HtmlDocumentWithVar();
  extVar.title = title;

  setProperty(extSetter, 'title', title);
  setProperty(htmlDocument, 'title', title);
  Object htmlDocumentObj = htmlDocument;
  setProperty(htmlDocumentObj, 'title', title);
}
