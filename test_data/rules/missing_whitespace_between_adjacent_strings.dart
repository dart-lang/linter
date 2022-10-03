// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N missing_whitespace_between_adjacent_strings`

f(o) {
  f('long line' // LINT
    'is long');
  f('long $f line' // LINT
    'is long');
  f('long line' ' is long'); // OK
  f('long line ' 'is long'); // OK
  f('long $f line ' 'is long'); // OK
  f('longLineWithoutSpaceCouldBe' 'AnURL'); // OK
  f('long line\n' 'is long'); // OK
  f('long line\r' 'is long'); // OK
  f('long line\t' 'is long'); // OK

  f(RegExp('(\n)+' '(\n)+' '(\n)+')); // OK
  matches('(\n)+' '(\n)+' '(\n)+'); // OK

  f('Hello' // OK
    '${1 == 2 ? ', world' : ''}');
  f('${1 == 2 ? 'Hello ' : ''}' // OK
    'world');

  f('${1 + 1}(' // OK
    'long line)');

  f('a $o' // OK
    'b');
  f('a' // OK
    '$o b');
  f("a $o b" // OK
    " c$o");
}

void matches(String value) {}
