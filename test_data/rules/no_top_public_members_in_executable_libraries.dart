// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N no_top_public_members_in_executable_libraries`

import 'package:meta/meta.dart';

main() {} // OK

const a = 1; // LINT

int v = 1; // LINT

typedef A = String; // LINT

class C {} // LINT

mixin M {} // LINT

enum E { e } // LINT

void f() {} // LINT

_insideFunction() {
  inner() {} // OK
}

@visibleForTesting
void forTest() {} // OK
