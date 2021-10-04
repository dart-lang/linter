// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'avoid_function_literals_in_foreach_calls.dart'
    as avoid_function_literals_in_foreach_calls;
import 'avoid_init_to_null.dart' as avoid_init_to_null;
import 'missing_whitespace_between_adjacent_strings.dart'
    as missing_whitespace_between_adjacent_strings;
import 'null_closures.dart' as null_closures;
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
import 'prefer_generic_function_type_aliases.dart'
    as prefer_generic_function_type_aliases;
import 'prefer_spread_collections.dart' as prefer_spread_collections;
import 'super_goes_last.dart' as super_goes_last;
import 'type_init_formals.dart' as type_init_formals;
import 'unawaited_futures.dart' as unawaited_futures;
import 'unnecessary_null_checks.dart' as unnecessary_null_checks;
import 'void_checks.dart' as void_checks;

void main() {
  avoid_function_literals_in_foreach_calls.main();
  avoid_init_to_null.main();
  missing_whitespace_between_adjacent_strings.main();
  null_closures.main();
  overridden_fields.main();
  prefer_asserts_in_initializer_lists.main();
  prefer_collection_literals.main();
  prefer_const_constructors.main();
  prefer_const_constructors_in_immutables.main();
  prefer_const_literals_to_create_immutables.main();
  prefer_contains.main();
  prefer_generic_function_type_aliases.main();
  prefer_spread_collections.main();
  super_goes_last.main();
  type_init_formals.main();
  unawaited_futures.main();
  unnecessary_null_checks.main();
  void_checks.main();
}
