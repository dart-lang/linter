// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:linter/src/analyzer.dart';

/// AST Spelunker
void main(List<String> args) {
  var parser = ArgParser();

  var options = parser.parse(args);
  for (var path in options.rest) {
    FileSpelunker(path).spelunk();
  }
}
