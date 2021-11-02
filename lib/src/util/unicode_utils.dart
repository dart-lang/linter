// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-42574
/// https://blog.rust-lang.org/2021/11/01/cve-2021-42574.html
/// U+202A, U+202B, U+202C, U+202D, U+202E, U+2066, U+2067, U+2068, U+2069.
var _unsafe = const [
  '\u202A',
  '\u202B',
  '\u202C',
  '\u202D',
  '\u202E',
  '\u2066',
  '\u2067',
  '\u2068',
  '\u2069',
].map((u) => u.codeUnitAt(0));

/// Check if the given code unit corresponds with an unsafe unicode character.
bool unsafe(int c) => _unsafe.contains(c);
