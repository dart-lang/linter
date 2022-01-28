// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'annotate_overrides.dart' as annotate_overrides;
import 'avoid_annotating_with_dynamic.dart' as avoid_annotating_with_dynamic;
import 'avoid_function_literals_in_foreach_calls.dart'
    as avoid_function_literals_in_foreach_calls;
import 'avoid_init_to_null.dart' as avoid_init_to_null;
import 'avoid_redundant_argument_values.dart'
    as avoid_redundant_argument_values;
import 'avoid_returning_this.dart' as avoid_returning_this;
import 'avoid_shadowing_type_parameters.dart'
    as avoid_shadowing_type_parameters;
import 'avoid_types_as_parameter_names.dart' as avoid_types_as_parameter_names;
import 'avoid_unused_constructor_parameters.dart'
    as avoid_unused_constructor_parameters;
import 'conditional_uri_does_not_exist.dart' as conditional_uri_does_not_exist;
import 'deprecated_consistency.dart' as deprecated_consistency;
import 'file_names.dart' as file_names;
import 'literal_only_boolean_expressions.dart'
    as literal_only_boolean_expressions;
import 'missing_whitespace_between_adjacent_strings.dart'
    as missing_whitespace_between_adjacent_strings;
import 'non_constant_identifier_names.dart' as non_constant_identifier_names;
import 'null_closures.dart' as null_closures;
import 'omit_local_variable_types.dart' as omit_local_variable_types;
import 'overridden_fields.dart' as overridden_fields;
import 'prefer_asserts_in_initializer_lists.dart'
    as prefer_asserts_in_initializer_lists;
import 'prefer_collection_literals.dart' as prefer_collection_literals;
import 'prefer_const_constructors.dart' as prefer_const_constructors;
import 'prefer_const_constructors_in_immutables.dart'
    as prefer_const_constructors_in_immutables;
import 'prefer_const_literals_to_create_immutables.dart'
    as prefer_const_literals_to_create_immutables;
import 'prefer_contains.dart' as prefer_contains;
import 'prefer_equal_for_default_values.dart'
    as prefer_equal_for_default_values;
import 'prefer_generic_function_type_aliases.dart'
    as prefer_generic_function_type_aliases;
import 'prefer_spread_collections.dart' as prefer_spread_collections;
import 'super_goes_last.dart' as super_goes_last;
import 'tighten_type_of_initializing_formals.dart'
    as tighten_type_of_initializing_formals;
import 'type_init_formals.dart' as type_init_formals;
import 'unawaited_futures.dart' as unawaited_futures;
import 'unnecessary_getters_setters.dart' as unnecessary_getters_setters;
import 'unnecessary_null_checks.dart' as unnecessary_null_checks;
import 'unnecessary_overrides.dart' as unnecessary_overrides;
import 'use_is_even_rather_than_modulo.dart' as use_is_even_rather_than_modulo;
import 'void_checks.dart' as void_checks;

void main() {
  annotate_overrides.main();
  avoid_annotating_with_dynamic.main();
  avoid_function_literals_in_foreach_calls.main();
  avoid_init_to_null.main();
  avoid_redundant_argument_values.main();
  avoid_returning_this.main();
  avoid_shadowing_type_parameters.main();
  avoid_types_as_parameter_names.main();
  avoid_unused_constructor_parameters.main();
  conditional_uri_does_not_exist.main();
  deprecated_consistency.main();
  file_names.main();
  literal_only_boolean_expressions.main();
  missing_whitespace_between_adjacent_strings.main();
  non_constant_identifier_names.main();
  null_closures.main();
  omit_local_variable_types.main();
  overridden_fields.main();
  prefer_asserts_in_initializer_lists.main();
  prefer_collection_literals.main();
  prefer_const_constructors.main();
  prefer_const_constructors_in_immutables.main();
  prefer_const_literals_to_create_immutables.main();
  prefer_contains.main();
  prefer_equal_for_default_values.main();
  prefer_generic_function_type_aliases.main();
  prefer_spread_collections.main();
  super_goes_last.main();
  tighten_type_of_initializing_formals.main();
  type_init_formals.main();
  unawaited_futures.main();
  unnecessary_getters_setters.main();
  unnecessary_null_checks.main();
  unnecessary_overrides.main();
  use_is_even_rather_than_modulo.main();
  void_checks.main();
}
