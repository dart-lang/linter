// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N null_check_on_nullable_type_parameter`

T m1<T>(T p) => p!; // OK
T m2a<T>(T? p) => p!; // LINT
dynamic m2b<T>(T? p) => p!; // OK
T m3<T extends Object>(T? p) => p!; // OK
T m4<T extends Object?>(T? p) => p!; // LINT
T m5<T extends dynamic>(T? p) => p!; // LINT
int m6<T>(T? p) => p!.hashCode; // OK
String m7<T>(T? p) => p!.toString(); // OK
T m8<T>(T? p) => p!..toString(); // OK

T m10<T>(T? p) { return p!; } // LINT
T? m20<T>(T? p) { T t = p!; } // LINT
T m30<T>(T? p) {
  T t;
  t = p!; // LINT
  return t;
}
class C<T> {
  late T t;
  m(T? p) {
    t = p!; // LINT
  }
}

R m<P, R>(P? p) => p! as R; // OK
