// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N unused_top_members_in_executable_libraries`

import 'package:meta/meta.dart';

main() // OK
{
  _f5();
  f1();
  f3(() {
    f4(b);
  });
  f4(b);
}

const a = 1; // LINT
const b = 1; // OK

int v = 1; // LINT

typedef A = String; // LINT

class C {} // LINT

mixin M {} // LINT

enum E { e } // LINT

void f() {} // LINT

@visibleForTesting
void forTest() {} // OK

void f1() // OK
{
  f2();
}

void f2() // OK
{
  f1();
}

void f3(Function f) {} //OK
void f4(int p) {} //OK

int id = 0; // OK
void _f5() {
  id++;
}

@pragma('vm:entry-point')
void f6() {} // OK
