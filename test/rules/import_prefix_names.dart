// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N import_prefix_names`

import 'dart:io' as IO; // LINT
import 'dart:io' as io; // OK
import 'dart:io' as IO_io; // LINT
import 'dart:io' as io_io; // OK