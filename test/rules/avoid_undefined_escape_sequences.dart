// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_undefined_escape_sequences`

main() {
  final okLiteral = 'z is OK'; // OK
  final badLiteral = '\z is not OK'; // LINT
  final badAdjacentStrings = '\z lint here, ' 'no lint there'; // LINT
  final badInterpolationString = '\z has some interpolation $okLiteral'; // LINT

  final okSingleQuoteEscape = 'this has a single quote \''; // OK
  final okDoubleQuote = "some double quote \", and a single quote to make double quotes necessary'"; // OK

  final unnecessarySingleQuoteEscape = "not needed \'"; // LINT
  final unnecessaryDoubleQuoteEscape = 'not needed \"'; // LINT
}
