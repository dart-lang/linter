// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N unnecessary_null_check`

int? i;

int? j = i!; // LINT

m1(int? p) => m1(i!); // LINT

m2({required String s, int? p}) => m2(p: i!, s: ''); // LINT

class A {
  A([int? p]) {
    A(i!); // LINT
  }

  m1(int? p) => m1(i!); // LINT

  m2({required String s, int? p}) => m2(p: i!, s: ''); // LINT

  operator +(int? p) => A() + i!; // LINT
}
