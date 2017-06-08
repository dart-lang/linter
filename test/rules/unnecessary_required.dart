// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N unnecessary_required`

// Hack to work around issues importing `meta.dart` in tests.
// Ideally, remove:
library meta;

class _Required {
  const _Required();
}

const _Required required = const _Required();

m1(
  @required a, // LINT
) =>
    null;

m2([
  @required a, // LINT
]) =>
    null;

m3({
  @required a, // OK
}) =>
    null;

class A {
  m1(
    @required a, // LINT
  ) =>
      null;

  m2([
    @required a, // LINT
  ]) =>
      null;

  m3({
    @required a, // OK
  }) =>
      null;
}
