// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N cast_to_non_nullable_child`

class A {}
class B extends A {}

m() {
  var v;

  A? a;
  v = a as B; // LINT
  v = a as B?; // OK
  v = a as A; // OK

  // exclude dynamic
  dynamic b;
  v = b as B; // OK
  v = b as B?; // OK
}
