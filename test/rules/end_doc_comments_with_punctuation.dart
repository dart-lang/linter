// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N end_doc_comments_with_punctuation`

// BAD

// LINT [+1]
/// This sentence doesn't have any terminating punctuation at the end
void a() => null;

// LINT [+2]
/// This is a long documentation comment composed of multiple sentences.
/// However, it looks like we forgot to terminate the last one, which is bad
void b() => null;

// LINT [+4]
// ignore: slash_for_doc_comments
/**
 * We also flag Java-style documentation comments, such as this long one we have
 * spread across multiple lines here
 */
void c() => null;

// GOOD

// OK
/// This sentence is properly terminated with a period.
void d() => null;

// OK
/// This is a very long sentence spread across multiple lines of a documentation
/// comment, but it still ends with terminating punctuation!
void e() => null;

// OK
// ignore: slash_for_doc_comments
/**
 * This Java-style documentation comment is properly terminated.
 */
void f() => null;

// OK
/// A question mark works too, would you like to see?
void g() => null;
