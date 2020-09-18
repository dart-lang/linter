// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N null_check_on_nullable_type_parameter`

m1<T>(T p) => p!; // LINT
m2<T>(T? p) => p!; // LINT
m3<T extends Object>(T p) => p!; // OK
m4<T extends Object?>(T p) => p!; // LINT
m5<T extends dynamic>(T p) => p!; // LINT
m6<T extends dynamic>(T p) => p!.a; // OK
m7<T extends dynamic>(T p) => p!.m(); // OK

m10<T>(T p) { return p!; } // LINT
m20<T>(T? p) { T t = p!; } // LINT
