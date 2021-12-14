// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../analyzer.dart';

/// Base type for all compliance checks for web libraries.
class ConformanceRule extends LintRule {
  ConformanceRule(
      {required String name,
      required String description,
      required String details})
      : super(
            name: name,
            details: details,
            description: description,
            group: Group.errors);
}
