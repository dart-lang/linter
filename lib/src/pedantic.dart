// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Locally cached enumeration of `package:pedantic`-defined lints, used for
/// setting `dartanalyzer` CLI rule defaults.
///
/// Validated by test/pedantic_test.dart
class Pedantic {
  /// Current version of pedantic.
  static const String version = '1.4.0';

  /// Pedantic-defined lint rules for [version].
  static List<String> rules = [
    'avoid_empty_else',
    'avoid_init_to_null',
    'avoid_relative_lib_imports',
    'avoid_return_types_on_setters',
    'avoid_types_as_parameter_names',
    'no_duplicate_case_values',
    'null_closures',
    'prefer_contains',
    'prefer_equal_for_default_values',
    'prefer_is_empty',
    'prefer_is_not_empty',
    'recursive_getters',
    'unrelated_type_equality_checks',
    'use_rethrow_when_possible',
    'unawaited_futures',
    'valid_regexps',
  ];
}
