// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N adjacent_strings_to_concatenate_literals`

main() {
  String string1 = 'hola means' + // LINT
      ' hello in spanish';

  String string2 = 'hola means' // OK
      ' hello in spanish';

  List<String> list = ['this is' + // LINT
    ' not allowed'];
}
