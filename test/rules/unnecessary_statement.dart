// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N unnecessary_statement`

void main() {
  int a;
  ; // OK because it is linted for other rule.
  a; // LINT
  a + a; // OK because + could have side-effects.
  a = 5; // OK
  bool x;
  x ? 0 : 3; // LINT
  foo() ? 0 : 3; // OK
  x ? foo() : 3; // OK
  x ? 3 : foo(); // OK
  foo(); // OK
  try {
    foo();
  } on Exception {
    rethrow; // OK
  }
  throw new Exception(); // OK
}

bool foo() => true;
