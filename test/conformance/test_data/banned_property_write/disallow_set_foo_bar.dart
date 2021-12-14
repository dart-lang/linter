// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Test that native types that don't have a `dart:html` `@Native` class
// equivalent are still checked.

@JS()
library disallow_set_foo_bar;

import 'dart:js_util';
import 'package:js/js.dart';

@JS()
class FooWithSetter {
  external FooWithSetter();
  // Silence avoid_setters_without_getters.
  external String get bar;
  external set bar(String val);
}

@JS()
class FooWithVar {
  external FooWithVar();
  external String bar;
}

@JS()
@staticInterop
class StaticFooWithSetter {
  external StaticFooWithSetter();
}

extension StaticFooWithSetterExtension on StaticFooWithSetter {
  external set bar(String val);
}

@JS()
@staticInterop
class StaticFooWithNonExternal {
  external StaticFooWithNonExternal();
}

extension StaticFooWithSetterNonExternalExtension on StaticFooWithNonExternal {
  set bar(String val) {}
  set barWithJsUtil(String val) =>
      setProperty<String>(this, 'bar', val); // LINT
}

void main() {
  var bar = 'bar';

  var fooSetter = FooWithSetter();
  fooSetter.bar = bar; // LINT
  (fooSetter as dynamic).bar = bar; // LINT

  var fooVar = FooWithVar();
  fooVar.bar = bar; // LINT

  var staticFooSetter = StaticFooWithSetter();
  staticFooSetter.bar = bar; // LINT

  var staticFooNonExt = StaticFooWithNonExternal();
  staticFooNonExt.bar = bar;

  setProperty(fooSetter, 'bar', bar); // LINT
  setProperty(staticFooSetter, 'bar', bar); // LINT
  Object fooObj = fooSetter;
  setProperty(fooObj, 'bar', bar); // LINT
}
