// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N use_late`

int? i; // OK

int? _i1; // LINT

int? _i2; // LINT
m2() {
  _i2 = 1;
}

int? _i3; // OK
m3() {
  _i3 = null;
}

int? _i4; // LINT
m4() {
  _i4!.abs();
}

int? _i5; // OK
m5() {
  _i5?.abs();
}

int? _i6; // OK
m6() {
  if (_i6 != null) _i6.abs();
}

int? _i7; // OK
m7(int? i) {
  m7(_i7);
}

int? _i8; // LINT
m8(int i) {
  m8(_i8!);
}

int? _i9; // OK
m9() {
  _i9 == 1;
}
