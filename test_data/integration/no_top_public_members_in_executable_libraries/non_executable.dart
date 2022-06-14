// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N no_top_public_members_in_executable_libraries`

const a = 1; // OK

int v = 1; // OK

typedef A = String; // OK

class C {} // OK

mixin M {} // OK

enum E { e } // OK

void f() {} // OK
