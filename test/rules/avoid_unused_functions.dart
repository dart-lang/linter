// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_unused_tearoffs`

notReturned() {
  1; // OK
  1 + 1; // OK
  foo; // LINT
  new MyClass().foo; // LINT
  new MyClass()..foo; // LINT
  new MyClass()
    ..getter // OK
    ..foo() // OK
    ..foo; // LINT
  []; // OK
  <dynamic, dynamic>{}; // OK
  "blah"; // OK
  ~1; // OK

  new MyClass(); // OK
  foo(); // OK
  new MyClass().foo(); // OK
  var x = 2; // OK
  x++; // OK
  x--; // OK
  ++x; // OK
  --x; // OK
  try {
    throw new Exception(); // OK
  } catch (x) {
    rethrow; // OK
  }
}

asConditionAndReturnOk() {
  if (true == someBool) // OK
  {
    return 1 + 1; // OK
  } else if (false == someBool) {
    return foo; // OK
  }
  while (new MyClass() != null) // OK
  {
    return new MyClass().foo; // OK
  }
  while (null == someBool) // OK
  {
    return new MyClass()..foo; // LINT
  }
  for (; someBool ?? someBool;) // OK
  {
    return <dynamic, dynamic>{}; // OK
  }
  do {} while ("blah".isEmpty); // OK
  for (var i in []) {} // OK
  switch (~1) // OK
      {
  }

  () => new MyClass().foo; // LINT
  myfun() => new MyClass().foo; // OK
  myfun2() => new MyClass()..foo; // LINT
}

myfun() => new MyClass().foo; // OK
myfun2() => new MyClass()..foo; // LINT

expressionBranching() {
  null ?? 1 + 1; // OK
  null ?? foo; // LINT
  null ?? new MyClass().foo; // LINT
  false || 1 + 1 == 2; // OK
  false || foo == true; // OK
  false || new MyClass() as bool; // OK
  false || new MyClass().foo == true; // OK
  true && 1 + 1 == 2; // OK
  true && foo == true; // OK
  true && new MyClass() as bool; // OK
  true && new MyClass().foo == true; // OK

  // ternaries can detect either/both sides
  someBool // OK
      ? 1 + 1 // OK
      : foo(); // OK
  someBool // OK
      ? foo() // OK
      : foo; // LINT
  someBool // OK
      ? new MyClass() // OK
      : foo(); // OK
  someBool // OK
      ? foo() // OK
      : new MyClass().foo; // LINT
  someBool // OK
      ? [] // OK
      : {}; // OK

  // not unnecessary condition, but unnecessary branching
  foo() ?? 1 + 1; // OK
  foo() || new MyClass() as bool; // OK
  foo() && foo == true; // OK
  foo() ? 1 + 1 : foo(); // OK
  foo() ? foo() : foo; // LINT
  foo() ? foo() : new MyClass().foo; // LINT

  null ?? new MyClass(); // OK
  null ?? foo(); // OK
  null ?? new MyClass().foo(); // OK
  false || foo(); // OK
  false || new MyClass().foo(); // OK
  true && foo(); // OK
  true && new MyClass().foo(); // OK
  someBool ? foo() : new MyClass().foo(); // OK
  foo() ? foo() : new MyClass().foo(); // OK
  foo() ? new MyClass() : foo(); // OK
}

inOtherStatements() {
  if (foo()) {
    1; // OK
  }
  while (someBool) {
    1 + 1; // OK
  }
  for (foo; foo();) {} // LINT
  for (; foo(); 1 + 1) {} // OK
  for (;
      foo();
      foo(), // OK
      1 + 1, // OK
      new MyClass().foo) {} // LINT
  do {
    new MyClass().foo; // LINT
  } while (foo());

  switch (foo()) {
    case true:
      []; // OK
      break; // OK
    case false:
      <dynamic, dynamic>{}; // OK
      break; // OK
    default:
      "blah"; // OK
  }

  for (var i in [1, 2, 3]) {
    ~1; // OK
  }
}

bool someBool = true;
bool foo() => true;

class MyClass {
  bool foo() => true;

  get getter => true;
}
