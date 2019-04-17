// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N unsafe_script_src`

import 'dart:html';

void main() {
  var script = ScriptElement();
  script.src = 'foo.js'; // LINT
  var src = 'foo.js'; // OK
  var src2 = script.src; // OK
  script
    ..type = 'application/javascript'
    ..src = 'foo.js'; // LINT
  script
    ..src = 'foo.js' // LINT
    ..type = 'application/javascript';
  script?.src = 'foo.js'; // LINT

  C().src = 'foo.js'; // OK
  C()..src = 'foo.js'; // OK
  C()?.src = 'foo.js'; // OK

  dynamic d;
  d.src = 'foo.js'; // LINT
  (script as dynamic).src = 'foo.js'; // LINT
}

class C {
  String src;
}
