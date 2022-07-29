// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N unused_top_members_in_executable_libraries`

import 'package:meta/meta.dart';

/// see [Comment]
main() // OK
{
  _f5();
  f1();
  f3(() {
    f4(b);
  });
  f4(b);
  usageInTypeBound();
  usageInFunctionType();
  usageInDefaultValue();
  usageInAnnotation();
  Future<C5>.value(C5()).extensionUsage();
  accessors();
}

class Comment {} // LINT

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

void f3(Function f) {} // OK
void f4(int p) {} // OK

int id = 0; // OK
void _f5() {
  id++;
}

@pragma('vm:entry-point')
void f6() {} // OK

const entryPoint = pragma('vm:entry-point');
@entryPoint
void f7() {} // OK

@pragma('other') // LINT
void f8() {}

// test accessors
int get id9 => 0;
void set id9(int value) {}
void accessors() {
  id9 += 4; // usage
}

// Usage in type bound
class C1 {}

void usageInTypeBound<T extends C1>() {}

// Usage in Function type
class C2 {}

void Function(C2)? usageInFunctionType() {}

// Usage in default value
class C3 {
  const C3();
}

void usageInDefaultValue([Object? p = const C3()]) {}

// Usage in annotation
class C4 {
  const C4();
}

@C4()
void usageInAnnotation() {}

// Usage in type parameter in extension `on` clause.
class C5 {}

extension UsedPublicExt on Future<C5> {
  extensionUsage() {}
}

// Usage in type parameter in extension `on` clause.
class C6 {} //LINT

extension UnusedPublicExt on C6 //LINT
{
  m() {}
}
