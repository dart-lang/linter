// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.6

import 'opted_in.dart';

main() {
  // a from opted-out
  v1?.substring(0); // LINT
  v1?.length; // LINT
  v1.length; // OK
  v1 != null; // LINT
  v1 == null; // LINT
  null != v1; // LINT
  null == v1; // LINT
  v1 != ''; // OK
  v1 == ''; // OK

  // b from opted-out
  v2?.substring(0); // OK
  v2?.length; // OK
  v2.length; // OK
  v2 != null; // OK
  v2 == null; // OK
  null != v2; // OK
  null == v2; // OK
  v2 != ''; // OK
  v2 == ''; // OK

  f1()?.length; // LINT
  f2()?.length; // OK

  C1().p?.length; // LINT
  C2().p?.length; // OK

  C1().m()?.length; // LINT
  C2().m()?.length; // OK
}

String v2;

String f2() => null;

class C2 {
  String p = '';
  String m() => '';
}
