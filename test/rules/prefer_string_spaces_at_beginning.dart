// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N prefer_string_spaces_at_beginning`

main() {
  // No sane lint rule could catch this. :(
  String standalone1 = 'nospaces'; // OK
  String standalone2 = 'space on the right '; // OK

  // No sane lint rule could catch this. :(
  String trailing1 = 'adjacent strings' 'trailing space on the right '; // OK
  String trailing2 = 'catted strings' + 'trailing space on the right '; // OK

  // test for adjacent strings (preferred)
  String adj1 = 'adjacent strings ' 'with space at the end'; // LINT
  String adj2 = 'adjacent strings' ' with space at the beginning'; // OK
  String adj3 = 'multiple adjacent strings ' // LINT
      'all of which have the wrong style ' // LINT
      'of spaces being on the right'; // OK
  String adj4 = 'multiple adjacent strings' // OK
      ' all of which have the right style' // OK
      ' of spaces being on the left'; // OK

  // test for concatenated strings (for those not linting this)
  String cat1 = 'concatenated strings ' + 'with space at the end'; // LINT
  String cat2 = 'concatenated strings' + ' with space at the beginning'; // OK
  String cat3 = 'multiple concatenated strings ' + // LINT
      'all of which have the wrong style ' + // LINT
      'of spaces being on the right'; // OK
  String cat4 = 'multiple adjacent strings' + // OK
      ' all of which have the right style' + // OK
      ' of spaces being on the left'; // OK

  // test a mixture of the two, for those who really hate doing things right
  String mixedWrong = 'mixture of adjacent strings ' // LINT
      'and concatenated strings too ' + // LINT
      'all of which use the wrong style ' // LINT
      'of spaces being on the right'; // OK
  String mixedRight = 'mixture of adjacent strings' //  OK
      ' and concatenated strings too' + //  OK
      ' all of which use the wrong style' // OK
      ' of spaces being on the right'; // OK

  // Usually regexes, html, or special formats. Ignore.
  String rawStrings1 = r'can do ' r' any strategy with ' r' adjacents '; // OK
  String rawStrings2 = r'can do ' + r' any strategy with ' + r' catting '; // OK

  String aStringVar = '';

  String varConcatenation = 'trailing space allowed here ' + aStringVar; // OK
}
