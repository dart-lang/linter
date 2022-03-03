// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N unnecessary_null_checks`

int? i;

int? j1 = i!; // LINT
int? j2 = (i!); // LINT

m1a(int? p) => m1a(i!); // LINT
m1b(int? p) => m1b((i!)); // LINT

m2a({required String s, int? p}) => m2a(p: i!, s: ''); // LINT
m2b({required String s, int? p}) => m2b(p: (i!), s: ('')); // LINT

class A {
  A([int? p]) {
    A(i!); // LINT
    A((i!)); // LINT
  }

  m1a(int? p) => m1a(i!); // LINT
  m1b(int? p) => m1b((i!)); // LINT

  m2a({required String s, int? p}) => m2a(p: i!, s: ''); // LINT
  m2b({required String s, int? p}) => m2b(p: (i!), s: ('')); // LINT

  m3a(int? p) => p!; // OK
  m3b(int? p) {
    return p!; // OK
  }

  operator +(int? p) => A() + i!; // LINT
  operator -(int? p) => A() + (i!); // LINT
}

int? f1(int? i) => i!; // LINT
int? f2(int? i) { return i!; } // LINT

f3(int? i) {
  int? v;
  v = i!; // LINT
}

f4(int? p) {
  int? v;
  v ??= 1;
  v += p!; // OK
}

autoPromote() {
  int? v2;
  v2 = v2!; // OK
}

f5(int? p) {
  int? v1;
  v1 ??= p!; // OK
}

Future<int?> f6(int? p) async => await p!; // LINT
List<int?> f7(int? p) => [p!]; // LINT
Set<int?> f8(int? p) => {p!}; // LINT
Map<int?, String> f9(int? p) => {p!: ''}; // LINT
Map<String, int?> f10(int? p) => {'': p!}; // LINT
Iterable<int?> f11(int? p) sync* {yield p!;} // LINT
Stream<int?> f12(int? p) async* {yield p!;} // LINT
Future<void> f13(int? p) async {
  var f = Future(() => p);
  int? i;
  i = await f!; // LINT
}
Future<int?> f14(int? p) async => p!; // LINT
