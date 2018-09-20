// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N no_legacy_typedefs`

typedef String BadNoParameters(); // LINT
typedef bool BadOneDynamicParameter(num); // LINT
typedef bool BadOneParameter(num value); // LINT
typedef int BadGenericWithDynamicParameters<T>(a, b); // LINT
typedef int BadGeneric<T>(T a, T b); // LINT
typedef Foo BadReturnsFoo(); // LINT

typedef GoodNoParameters = String Function(); // OK
typedef GoodOneParameter = bool Function(num); // OK
typedef GoodOneNamedParameter = bool Function(num value); // OK
typedef GoodGeneric<T> = int Function(T, T); // OK
typedef GoodGenericWithNamedParameters<T> = int Function(T a, T b); // OK
typedef GoodReturnsFoo = Foo Function(); // OK

class Foo {}
