// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N prefer_final_parameters`

void badFunction(String label) { // LINT
  print(label);
}

void goodFunction(final String label) { // OK
  print(label);
}

void badExpression(int value) => print(value); // LINT

void goodExpression(final int value) => print(value); // OK

bool _testingVariable;

void set badSet(bool setting) => _testingVariable = setting; // LINT

void set goodSet(final bool setting) => _testingVariable = setting; // OK

var badClosure = (Object random) { // LINT
  print(random);
};

var goodClosure = (final Object random) { // OK
  print(random);
};

void badMixed(String bad, final String good) { // LINT
  print(bad);
  print(good);
}

void goodMultiple(final String bad, final String good) { // OK
  print(bad);
  print(good);
}

void mutableCase(String label) { // OK
  print(label);
  label = 'Lint away!';
  print(label);
}

void mutableExpression(int value) => value = 3; // OK

class C {
  String value = '';
  int _contents = 0;

  C(String content) { // LINT
    _contents = content.length;
  }

  C.bad(int contents): _contents = contents; // LINT

  C.good(final int contents): _contents = contents; // OK

  factory C.theValueGood(this.value); // OK

  factory C.theValueBad(String value): this.value = value; // LINT

  void set badContents(int contents) => _contents = setting; // LINT
  void set goodContents(final int contents) => _contents = setting; // OK

  int get contentValue => _contents + 4; // OK

  void badMethod(String bad) { // LINT
    print(bad);
  }

  void goodMethod(final String good) { // OK
    print(good);
  }

  @override
  C operator +(C other) { // LINT
    return C.good(contentValue + other.contentValue);
  }

  @override
  C operator -(final C other) { // OK
    return C.good(contentValue + other.contentValue);
  }
}
