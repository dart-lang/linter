// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N noop_string_calls`

f() {
  String? nullable;
  String s = 'hello';
  s + ''; // LINT
  s + 'a'; // OK

  s * 0; // OK
  s * 1; // LINT
  s * 2; // OK

  s.toString(); // LINT
  nullable.toString(); // OK

  s.substring(0); // LINT
  s.substring(1); // OK
  s.substring(0, 1); // OK

  s.padLeft(0); // LINT
  s.padLeft(1); // OK
  s.padRight(0); // LINT
  s.padRight(1); // OK

  s = 'hello'
      '' // LINT
      'world';
}
