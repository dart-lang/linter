// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N prefer_final_parameters`

void badMethod(String label) { // LINT
  print(label);
}

void badExpression(int value) => print(value); // LINT

void badMixed(String bad, final String good) { // LINT
  print(bad);
  print(good);
}

bool _testingVariable;

void set badSet(bool setting) => _testingVariable = setting; // LINT

var badCallback = (Object random) { // LINT
  print(random);
};

void goodMethod(final String label) { // OK
  print(label);
}

void goodExpression(final int value) => print(value); // OK

void goodMultiple(final String bad, final String good) { // OK
  print(bad);
  print(good);
}

void set goodSet(final bool setting) => _testingVariable = setting; // OK

var goodCallback = (final Object random) { // OK
  print(random);
};

void mutableCase(String label) { // OK
  print(label);
  label = 'Lint away!';
  print(label);
}

void mutableExpression(int value) => value = 3; // OK
