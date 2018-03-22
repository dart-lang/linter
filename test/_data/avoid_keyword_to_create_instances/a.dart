// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_keyword_to_create_instances`

class A {
  const A([o]);
  A.c1();
}

main() {
  const A(); // OK
  new A(); // LINT
  A(); // OK

  new A.c1(); // LINT
  A.c1(); // OK

  const A([]); // OK
  new A([]); // LINT
  A([]); // OK
  A(const []); // OK

  const A(A()); // OK
  A(const A()); // OK
  A(A()); // OK

  final v1 = A(); // OK
  final v2 = new A(); // LINT
  const v3 = const A(); // LINT
  const v4 = A(); // OK
  final v5 = const A([]); // OK
  const v6 = const A([]); // LINT
  const v7 = A([]); // OK
  final v8 = A(const []); // OK
}
