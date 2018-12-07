// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_undefined_and_unnecessary_escape_sequences`

// ignore_for_file: unused_local_variable, prefer_single_quotes
main() {
  const okLiteral = 'z'; // OK
  const badLiteral = '\z'; // LINT
  const badAdjacentStrings = '\z' 'z'; // LINT
  const badInterpolationString = '\z $okLiteral'; // LINT

  const okSingleQuoteEscape = '\''; // OK
  const okDoubleQuote = "\""; // OK

  const unnecessarySingleQuoteEscape = "\'"; // LINT
  const unnecessaryDoubleQuoteEscape = '\"'; // LINT

  const rawStringsAreIgnored = r'\z'; // OK
  const multilineLiteralsAreConsidered = '''\z'''; // LINT
}
