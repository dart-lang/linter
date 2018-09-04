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

class A {
  m1<T>() {}
  @optionalTypeArgs
  m2<T>() {}

  m() {
    A a;
    a.m1(); // LINT
    a.m1<int>(); // OK
    a.m2(); // OK
    a.m2<int>(); // OK
  }
}
