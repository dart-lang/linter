// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N voidness_propagation`
class A<T> {}

class B<T1, T2> {}

void_to_int() {
  A<void> a1;
  A<int> a2 = a1; // LINT

  B<void, void> b1;
  B<int, void> b2 = b1; // LINT
  B<int, int> b3 = b1; // LINT
  B<void, int> b4;
  B<int, int> b5 = b4; // LINT

  A<void> Function() f1;
  A<int> Function() f2 = f1; // LINT

  // errors
  // A<int> f3() { return A<void>(); }
  // A<int> f4() => A<void>();
}

void_to_object() {
  A<void> a1;
  A<Object> a2 = a1; // LINT

  B<void, void> b1;
  B<Object, void> b2 = b1; // LINT
  B<Object, Object> b3 = b1; // LINT
  B<void, Object> b4;
  B<Object, Object> b5 = b4; // LINT

  A<void> Function() f1;
  A<Object> Function() f2 = f1; // LINT

  A<Object> f3() {
    return A<void>(); // LINT
  }

  A<Object> f4() => A<void>(); // LINT
}

void_to_dynamic() {
  A<void> a1;
  A<dynamic> a2 = a1; // LINT

  B<void, void> b1;
  B<dynamic, void> b2 = b1; // LINT
  B<dynamic, dynamic> b3 = b1; // LINT
  B<void, dynamic> b4;
  B<dynamic, dynamic> b5 = b4; // LINT

  A<void> Function() f1;
  A<dynamic> Function() f2 = f1; // LINT

  A<dynamic> f3() {
    return A<void>(); // LINT
  }

  A<dynamic> f4() => A<void>(); // LINT
}

class C {
  A<dynamic> f1 = A<void>(); // LINT
  A<dynamic> m1() {
    return A<void>(); // LINT
  }

  A<dynamic> m2() => A<void>(); // LINT
}

abstract class D {
  List m1();
  List<void> m2();
  List<void> m3();
}

class E extends D {
  @override
  List<void> m1() => null; // LINT
  @override
  List m2() => null; // OK
  @override
  List<int> m3() => null; // OK
}

class F implements D {
  @override
  List<void> m1() => null; // LINT
  @override
  List m2() => null; // OK
  @override
  List<int> m3() => null; // OK
}
