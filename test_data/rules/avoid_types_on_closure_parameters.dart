// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N avoid_types_on_closure_parameters`

class Person {
  String name = '';
}

List<Person> people = [];

void closureAsParameter() {
  people.map((person) => person.name); // OK
  people.map((Person person) => person.name); // LINT
}

void assignmentWithSimpleParam() {
  String Function(Person)? v;
  v = (person) => person.name; // OK
  v = (Person person) => person.name; // LINT
}

void assignmentWithOptionalParam() {
  String? Function([Person?])? v;
  v = ([person]) => person?.name; // OK
  v = ([Person? person]) => person?.name; // LINT
}

void assignmentWithNamedParam() {
  String? Function({Person? person})? v;
  v = ({person}) => person?.name; // OK
  v = ({Person? person}) => person?.name; // LINT
}

void assignmentToDynamic() {
  dynamic v;
  v = (int a) {}; // OK
}

void assignmentToFunction() {
  Function v;
  v = (int a) {}; // OK
}

void assignmentToObject() {
  Object v;
  v = (int a) {}; // OK
}

void declaration() {
  var v1 = (Person person) => person.name; // OK
  String Function(Person) v2 = (Person person) => person.name; // LINT
}

void usageInList() {
  var l1 = <int Function(int)>[
    (int a) => 1, // LINT
  ];

  var l2 = [
    // TODO(a14n): uncomment the following line
    // (int a) => 1, // OK
  ];
}

// https://github.com/dart-lang/linter/issues/2131
const unused = Object();
void additionOfDefaultValue() {
  void Function({String name})? f;
  f = ({Object name = unused}) {}; // OK
}

Person Function({String name}) get g1 =>
    ({Object name = unused}) => Person(); // OK
Person Function({String name}) get g2 {
  return ({Object name = unused}) => Person(); // OK
}

void futureCatch() {
  Future? future;
  future?.then(
    (v) {},
    onError: (Object err, StackTrace stack) {}, // OK
  );
}
