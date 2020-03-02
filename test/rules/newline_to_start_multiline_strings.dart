// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N newline_to_start_multiline_strings`

f(o) {
  f(''''''); // OK
  f('''this is a multiline string'''); // OK
  // OK
  f('''
this is a multiline string''');
  // LINT [+1]
  f('''this
 is a multiline string''');

  f('''this is a multiline string $f'''); // OK
  // OK
  f('''
this is a multiline string $f''');
  // LINT [+1]
  f('''this
 is a multiline string$f''');
}
