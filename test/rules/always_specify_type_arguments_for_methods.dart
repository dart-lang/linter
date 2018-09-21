// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N always_specify_type_arguments_for_methods`

// Hack to work around issues importing `meta.dart` in tests.
// Ideally, remove:
library meta;

class _OptionalTypeArgs {
  const _OptionalTypeArgs();
}

const _OptionalTypeArgs optionalTypeArgs = const _OptionalTypeArgs();

// ... and replace w/:
// import 'package:meta/meta.dart';

@optionalTypeArgs
void g<T>() {}

void test() {
  g<dynamic>(); //OK
  g(); //OK
}

class A<R> {
  m1<T>() {}
  @optionalTypeArgs
  m2<T>() {}
  // no lint for method with return type and parameters all the same (m3 and m6)
  T m3<T>() => null;
  R m4<T>() => null;
  T m5<T>(int i) => null;
  T m6<T>(T i) => null;

  @optionalTypeArgs
  static A<T> f<T extends Object>() => null;

  m() {
    A<int> a;
    a.m1(); // LINT
    a.m1<int>(); // OK
    a.m2(); // OK
    a.m2<int>(); // OK
    a.m3(); // OK
    a.m3<int>(); // OK
    a.m4(); // LINT
    a.m4<int>(); // OK
    a.m5(null); // LINT
    a.m5<int>(null); // OK
    a.m6(null); // OK
    a.m6<int>(null); // OK
    A.f(); // OK
    A.f<int>(); // OK
  }
}
