// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_annotating_types_on_function_expressions`

class Person {
  String name;
}

List<Person> people;

var names = people.map((person) => person.name);
var names2 = people.map((Person person) => person.name); // LINT
