// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/io.dart';
import 'package:test/test.dart';

import 'config_test.dart' as config_test;
import 'formatter_test.dart' as formatter_test;
import 'integration_test.dart' as integration_test;
import 'io_test.dart' as io_test;
import 'linter_test.dart' as linter_test;
import 'project_test.dart' as project_test;
import 'pub_test.dart' as pub_test;

void main() {
  group('config', config_test.main);
  group('formatter', formatter_test.main);
  group('integration', integration_test.main);
  group('io', io_test.main);
  group('linter', linter_test.main);
  group('project', project_test.main);
  group('pub', pub_test.main);
}
