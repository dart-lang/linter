// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N use_null_aware_access`
m() {
  ''?.hashCode.toString(); // LINT
  ''.hashCode.toString(); // OK
  ''?.hashCode?.toString(); // OK

  ''?.hashCode.hashCode; // LINT
  ''.hashCode.hashCode; // OK
  ''?.hashCode?.hashCode; // OK

  ''?.toLowerCase().toString(); // LINT
  ''.toLowerCase().toString(); // OK
  ''?.toLowerCase()?.toString(); // OK

  ''?.toLowerCase().hashCode; // LINT
  ''.toLowerCase().hashCode; // OK
  ''?.toLowerCase()?.hashCode; // OK

  // test parenthesis
  (''?.hashCode).toString(); // LINT

  // test cascade
  ''?.hashCode..toString(); // LINT
  ''?.hashCode
    ..toString() // LINT
    ..toString(); // OK only the first cascade has lint

  m(); // OK

  (null as A)?.value = 2; // OK assignment handle null

  // call operator on null
  ''?.trim() + ''; // LINT

  // boolean expression must not be null
  ''?.isEmpty ? 'a' : 'b'; // LINT

  // boolean expression must not be null
  if (''?.isEmpty) // LINT
    ;
  else if (''?.isEmpty) // LINT
    ;
}

class A {
  int value;
}

main() {}
