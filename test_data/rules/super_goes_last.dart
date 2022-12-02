// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N super_goes_last`

class A {
  int a;
  A(this.a);
}

class B extends A {
  int _b;
  B(int a)
      : _b = a + 1,
        super(a); // OK
}
