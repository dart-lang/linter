// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N prefer_int_literals`

const double okDouble = 7.3; // OK
const double shouldBeInt = 8.0; // LINT
const inferredAsDouble = 8.0; // OK
Object inferredAsDouble2 = 8.0; // OK
dynamic inferredAsDouble3 = 8.0; // OK
final inferredAsDouble4 = 8.0 + 7.0; // OK
const double inferredAsDouble5 = 8.0 + // LINT
    7.0; // LINT

class A {
  var w = 7.0e2; // OK
  double x = 7.0e2; // LINT
  double y = 7.1e2; // LINT
  double z = 7.576e2; // OK
  A(this.x);
  namedDouble(String s, {double d}) {}
  namedDynamic(String s, {dynamic d}) {}
}

// TODO(danrubel): Report lint in these other situations

class B extends A {
  B.one() : super(1.0); // LINT
  B.two() : super(2.3); // OK
  B.three() : super(3);
  namedParam1() {
    namedDouble('should be int', d: 1.0); // LINT
  }

  namedParam2() {
    namedDynamic('should stay double', d: 1.0); // OK
  }
}

void takesDouble(double value) {}

double other() {
  takesDouble(3.0); // LINT

  double myDouble1 = 5.0; // LINT
  myDouble1 = myDouble1 + 3.7; // OK
  myDouble1 = 4.0 + myDouble1; // LINT
  myDouble1 = 4.0 - myDouble1; // LINT
  myDouble1 = 4.0 * myDouble1 / myDouble1; // LINT
  myDouble1 = 5.7 * myDouble1 / myDouble1; // OK

  var inferredAsInt = 3;

  var inferredAsDouble1 = inferredAsInt + 3.0; // OK
  var inferredAsDouble2 = inferredAsDouble1 + 3.7; // OK
  inferredAsDouble1 = inferredAsInt + 3.0; // OK
  inferredAsDouble2 = inferredAsDouble1 + 3.7; // OK

  // These next 4 could be LINT but static type info is not available
  var inferredAsDouble3 = inferredAsDouble2 + 3.0; // OK
  var inferredAsDouble4 = inferredAsDouble3 - 3.0; // OK
  inferredAsDouble3 = inferredAsDouble2 + 3.0; // OK
  inferredAsDouble4 = inferredAsDouble3 - 3.0; // OK

  return 6.0 + myDouble1 + inferredAsDouble4; // LINT
}
