// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N prefer_relative_imports`

import 'package:analyzer/analyzer.dart'; // OK
import 'prefer_is_empty.dart'; // OK
import 'package:linter/src/rules.dart'; // LINT
