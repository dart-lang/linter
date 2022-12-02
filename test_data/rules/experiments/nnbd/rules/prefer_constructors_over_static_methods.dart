// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N prefer_constructors_over_static_methods`

class A {
  static final array = <A>[];

  A.internal();

  static A bad1() => // LINT
      new A.internal();

  static A get newA => // LINT
      new A.internal();

  static A bad2() { // LINT
    final a = new A.internal();
    return a;
  }

  static A good1(int i) { // OK
    return array[i];
  }

  factory A.good2() { // OK
    return new A.internal();
  }

  factory A.good3() { // OK
    return new A.internal();
  }

  static A generic<T>() => // OK
      A.internal();

  static Object ok() => Object(); // OK

  static A? ok2() => 1==1 ? null : A.internal(); // OK
}

class B<T> {
  B.internal();

  static B<T> good1<T>(T one) => // OK
      B.internal();

  static B good2() => // OK
      B.internal();

  static B<int> good3() => // OK
      B<int>.internal();
}

extension E on A {
  static A foo() => A.internal(); // OK
}
