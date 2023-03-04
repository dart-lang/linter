# Linter for Dart

## Lint Rules

Welcome! For general information on using lint rules, see 
[Using the Linter](https://dart.dev/guides/language/analysis-options#enabling-linter-rules).
For information about configuring which lints are used, see the
[analysis options file](https://dart.dev/guides/language/analysis-options#the-analysis-options-file).
documentation.

Lints can also be used via predefined rulesets; common ones include:

* [core](https://github.com/dart-lang/lints) for official "core" Dart team lint
  rules.
* [recommended](https://github.com/dart-lang/lints) for additional lint rules
  "recommended" by the Dart team.
* [flutter](https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml)
  for rules recommended for Flutter projects (`flutter create` enables these by
  default).

## package:lints Core Rules

The following rules are included in the "core" Dart team lint rules (see
[core](https://github.com/dart-lang/lints/blob/main/lib/core.yaml)). To use
these rules, add a pubspec dependency on `package:lints` and create an
analysis_options.yaml file with the line:

```
include: package:lints/core.yaml
```

| Rule | Description |
| --- | --- |
| **[avoid_empty_else](rules/avoid_empty_else.md)** | Avoid empty else statements. |
| **[avoid_relative_lib_imports](rules/avoid_relative_lib_imports.md)** | Avoid relative imports for files in `lib/`. |
| **[avoid_shadowing_type_parameters](rules/avoid_shadowing_type_parameters.md)** | Avoid shadowing type parameters. |
| **[avoid_types_as_parameter_names](rules/avoid_types_as_parameter_names.md)** | Avoid types as parameter names. |
| **[await_only_futures](rules/await_only_futures.md)** | Await only futures. |
| **[camel_case_extensions](rules/camel_case_extensions.md)** | Name extensions using UpperCamelCase. |
| **[camel_case_types](rules/camel_case_types.md)** | Name types using UpperCamelCase. |
| **[curly_braces_in_flow_control_structures](rules/curly_braces_in_flow_control_structures.md)** | DO use curly braces for all flow control structures. |
| **[depend_on_referenced_packages](rules/depend_on_referenced_packages.md)** | Depend on referenced packages. |
| **[empty_catches](rules/empty_catches.md)** | Avoid empty catch blocks. |
| **[file_names](rules/file_names.md)** | Name source files using `lowercase_with_underscores`. |
| **[hash_and_equals](rules/hash_and_equals.md)** | Always override `hashCode` if overriding `==`. |
| **[iterable_contains_unrelated_type](rules/iterable_contains_unrelated_type.md)** | Invocation of Iterable<E>.contains with references of unrelated types. |
| **[list_remove_unrelated_type](rules/list_remove_unrelated_type.md)** | Invocation of `remove` with references of unrelated types. |
| **[no_duplicate_case_values](rules/no_duplicate_case_values.md)** | Don't use more than one case with same value. |
| **[non_constant_identifier_names](rules/non_constant_identifier_names.md)** | Name non-constant identifiers using lowerCamelCase. |
| **[null_check_on_nullable_type_parameter](rules/null_check_on_nullable_type_parameter.md)** | Don't use null check on a potentially nullable type parameter. |
| **[package_prefixed_library_names](rules/package_prefixed_library_names.md)** | Prefix library names with the package name and a dot-separated path. |
| **[prefer_generic_function_type_aliases](rules/prefer_generic_function_type_aliases.md)** | Prefer generic function type aliases. |
| **[prefer_is_empty](rules/prefer_is_empty.md)** | Use `isEmpty` for Iterables and Maps. |
| **[prefer_is_not_empty](rules/prefer_is_not_empty.md)** | Use `isNotEmpty` for Iterables and Maps. |
| **[prefer_iterable_whereType](rules/prefer_iterable_whereType.md)** | Prefer to use whereType on iterable. |
| **[prefer_typing_uninitialized_variables](rules/prefer_typing_uninitialized_variables.md)** | Prefer typing uninitialized variables and fields. |
| **[provide_deprecation_message](rules/provide_deprecation_message.md)** | Provide a deprecation message, via @Deprecated("message"). |
| **[unnecessary_overrides](rules/unnecessary_overrides.md)** | Don't override a method to do a super method invocation with the same parameters. |
| **[unrelated_type_equality_checks](rules/unrelated_type_equality_checks.md)** | Equality operator `==` invocation with references of unrelated types. |
| **[valid_regexps](rules/valid_regexps.md)** | Use valid regular expression syntax. |
| **[void_checks](rules/void_checks.md)** | Don't assign to void. |

## package:lints Recommended Rules

The following rules additional lint rules are recommended by the Dart team (see
[recommended](https://github.com/dart-lang/lints/blob/main/lib/recommended.yaml)).
To use these rules, add a pubspec dependency on `package:lints` and create an
analysis_options.yaml file with the line:

```
include: package:lints/recommended.yaml
```

| Rule | Description |
| --- | --- |
| **[always_require_non_null_named_parameters](rules/always_require_non_null_named_parameters.md)** | Specify `@required` on named parameters without defaults. `deprecated` |
| **[annotate_overrides](rules/annotate_overrides.md)** | Annotate overridden members. |
| **[avoid_function_literals_in_foreach_calls](rules/avoid_function_literals_in_foreach_calls.md)** | Avoid using `forEach` with a function literal. |
| **[avoid_init_to_null](rules/avoid_init_to_null.md)** | Don't explicitly initialize variables to null. |
| **[avoid_null_checks_in_equality_operators](rules/avoid_null_checks_in_equality_operators.md)** | Don't check for null in custom == operators. |
| **[avoid_renaming_method_parameters](rules/avoid_renaming_method_parameters.md)** | Don't rename parameters of overridden methods. |
| **[avoid_return_types_on_setters](rules/avoid_return_types_on_setters.md)** | Avoid return types on setters. |
| **[avoid_returning_null_for_void](rules/avoid_returning_null_for_void.md)** | Avoid returning null for void. |
| **[avoid_single_cascade_in_expression_statements](rules/avoid_single_cascade_in_expression_statements.md)** | Avoid single cascade in expression statements. |
| **[constant_identifier_names](rules/constant_identifier_names.md)** | Prefer using lowerCamelCase for constant names. |
| **[control_flow_in_finally](rules/control_flow_in_finally.md)** | Avoid control flow in finally blocks. |
| **[empty_constructor_bodies](rules/empty_constructor_bodies.md)** | Use `;` instead of `{}` for empty constructor bodies. |
| **[empty_statements](rules/empty_statements.md)** | Avoid empty statements. |
| **[exhaustive_cases](rules/exhaustive_cases.md)** | Define case clauses for all constants in enum-like classes. |
| **[implementation_imports](rules/implementation_imports.md)** | Don't import implementation files from another package. |
| **[library_names](rules/library_names.md)** | Name libraries using `lowercase_with_underscores`. |
| **[library_prefixes](rules/library_prefixes.md)** | Use `lowercase_with_underscores` when specifying a library prefix. |
| **[library_private_types_in_public_api](rules/library_private_types_in_public_api.md)** | Avoid using private types in public APIs. |
| **[no_leading_underscores_for_library_prefixes](rules/no_leading_underscores_for_library_prefixes.md)** | Avoid leading underscores for library prefixes. |
| **[no_leading_underscores_for_local_identifiers](rules/no_leading_underscores_for_local_identifiers.md)** | Avoid leading underscores for local identifiers. |
| **[null_closures](rules/null_closures.md)** | Do not pass `null` as an argument where a closure is expected. |
| **[overridden_fields](rules/overridden_fields.md)** | Don't override fields. |
| **[package_names](rules/package_names.md)** | Use `lowercase_with_underscores` for package names. |
| **[prefer_adjacent_string_concatenation](rules/prefer_adjacent_string_concatenation.md)** | Use adjacent strings to concatenate string literals. |
| **[prefer_collection_literals](rules/prefer_collection_literals.md)** | Use collection literals when possible. |
| **[prefer_conditional_assignment](rules/prefer_conditional_assignment.md)** | Prefer using `??=` over testing for null. |
| **[prefer_contains](rules/prefer_contains.md)** | Use contains for `List` and `String` instances. |
| **[prefer_equal_for_default_values](rules/prefer_equal_for_default_values.md)** | Use `=` to separate a named parameter from its default value. `removed` |
| **[prefer_final_fields](rules/prefer_final_fields.md)** | Private field could be final. |
| **[prefer_for_elements_to_map_fromIterable](rules/prefer_for_elements_to_map_fromIterable.md)** | Prefer 'for' elements when building maps from iterables. |
| **[prefer_function_declarations_over_variables](rules/prefer_function_declarations_over_variables.md)** | Use a function declaration to bind a function to a name. |
| **[prefer_if_null_operators](rules/prefer_if_null_operators.md)** | Prefer using if null operators. |
| **[prefer_initializing_formals](rules/prefer_initializing_formals.md)** | Use initializing formals when possible. |
| **[prefer_inlined_adds](rules/prefer_inlined_adds.md)** | Inline list item declarations where possible. |
| **[prefer_interpolation_to_compose_strings](rules/prefer_interpolation_to_compose_strings.md)** | Use interpolation to compose strings and values. |
| **[prefer_is_not_operator](rules/prefer_is_not_operator.md)** | Prefer is! operator. |
| **[prefer_null_aware_operators](rules/prefer_null_aware_operators.md)** | Prefer using null aware operators. |
| **[prefer_spread_collections](rules/prefer_spread_collections.md)** | Use spread collections when possible. |
| **[prefer_void_to_null](rules/prefer_void_to_null.md)** | Don't use the Null type, unless you are positive that you don't want void. |
| **[recursive_getters](rules/recursive_getters.md)** | Property getter recursively returns itself. |
| **[slash_for_doc_comments](rules/slash_for_doc_comments.md)** | Prefer using /// for doc comments. |
| **[type_init_formals](rules/type_init_formals.md)** | Don't type annotate initializing formals. |
| **[unnecessary_brace_in_string_interps](rules/unnecessary_brace_in_string_interps.md)** | Avoid using braces in interpolation when not needed. |
| **[unnecessary_const](rules/unnecessary_const.md)** | Avoid const keyword. |
| **[unnecessary_constructor_name](rules/unnecessary_constructor_name.md)** | Unnecessary `.new` constructor name. |
| **[unnecessary_getters_setters](rules/unnecessary_getters_setters.md)** | Avoid wrapping fields in getters and setters just to be "safe". |
| **[unnecessary_late](rules/unnecessary_late.md)** | Don't specify the `late` modifier when it is not needed. |
| **[unnecessary_new](rules/unnecessary_new.md)** | Unnecessary new keyword. |
| **[unnecessary_null_aware_assignments](rules/unnecessary_null_aware_assignments.md)** | Avoid null in null-aware assignment. |
| **[unnecessary_null_in_if_null_operators](rules/unnecessary_null_in_if_null_operators.md)** | Avoid using `null` in `if null` operators. |
| **[unnecessary_nullable_for_final_variable_declarations](rules/unnecessary_nullable_for_final_variable_declarations.md)** | Use a non-nullable type for a final variable initialized with a non-nullable value. |
| **[unnecessary_string_escapes](rules/unnecessary_string_escapes.md)** | Remove unnecessary backslashes in strings. |
| **[unnecessary_string_interpolations](rules/unnecessary_string_interpolations.md)** | Unnecessary string interpolation. |
| **[unnecessary_this](rules/unnecessary_this.md)** | Don't access members with `this` unless avoiding shadowing. |
| **[use_function_type_syntax_for_parameters](rules/use_function_type_syntax_for_parameters.md)** | Use generic function type syntax for parameters. |
| **[use_rethrow_when_possible](rules/use_rethrow_when_possible.md)** | Use rethrow to rethrow a caught exception. |

## package:flutter_lints Rules

The following rules are recommended for Flutter projects (`flutter create`
enables these by default); see
[flutter_lints](https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml).
To use these rules, add a pubspec dependency on `package:flutter_lints` and
create an analysis_options.yaml file with the line:

```
include: package:flutter_lints/flutter.yaml
```

| Rule | Description |
| --- | --- |
| **[avoid_print](rules/avoid_print.md)** | Avoid `print` calls in production code. |
| **[avoid_unnecessary_containers](rules/avoid_unnecessary_containers.md)** | Avoid unnecessary containers. |
| **[avoid_web_libraries_in_flutter](rules/avoid_web_libraries_in_flutter.md)** | Avoid using web-only libraries outside Flutter web plugin packages. |
| **[no_logic_in_create_state](rules/no_logic_in_create_state.md)** | Don't put any logic in createState. |
| **[prefer_const_constructors](rules/prefer_const_constructors.md)** | Prefer const with constant constructors. |
| **[prefer_const_constructors_in_immutables](rules/prefer_const_constructors_in_immutables.md)** | Prefer declaring const constructors on `@immutable` classes. |
| **[prefer_const_declarations](rules/prefer_const_declarations.md)** | Prefer const over final for declarations. |
| **[prefer_const_literals_to_create_immutables](rules/prefer_const_literals_to_create_immutables.md)** | Prefer const literals as parameters of constructors on @immutable classes. |
| **[sized_box_for_whitespace](rules/sized_box_for_whitespace.md)** | SizedBox for whitespace. |
| **[sort_child_properties_last](rules/sort_child_properties_last.md)** | Sort child properties last in widget instance creations. |
| **[use_build_context_synchronously](rules/use_build_context_synchronously.md)** | Do not use BuildContexts across async gaps. `experimental` |
| **[use_full_hex_values_for_flutter_colors](rules/use_full_hex_values_for_flutter_colors.md)** | Prefer an 8-digit hexadecimal integer(0xFFFFFFFF) to instantiate Color. |
| **[use_key_in_widget_constructors](rules/use_key_in_widget_constructors.md)** | Use key in widget constructors. |

## Additional Rules

The following are additional rules that can optionally be enabled. To use these
rules, create an analysis_options.yaml file with the following info:

```
linter:
  rules:
    - <rule name 1>
    - <rule name 2>
```

| Rule | Description |
| --- | --- |
| **[always_declare_return_types](rules/always_declare_return_types.md)** | Declare method return types. |
| **[always_put_control_body_on_new_line](rules/always_put_control_body_on_new_line.md)** | Separate the control structure expression from its statement. |
| **[always_put_required_named_parameters_first](rules/always_put_required_named_parameters_first.md)** | Put required named parameters first. |
| **[always_specify_types](rules/always_specify_types.md)** | Specify type annotations. |
| **[always_use_package_imports](rules/always_use_package_imports.md)** | Avoid relative imports for files in `lib/`. |
| **[avoid_annotating_with_dynamic](rules/avoid_annotating_with_dynamic.md)** | Avoid annotating with dynamic when not required. |
| **[avoid_bool_literals_in_conditional_expressions](rules/avoid_bool_literals_in_conditional_expressions.md)** | Avoid bool literals in conditional expressions. |
| **[avoid_catches_without_on_clauses](rules/avoid_catches_without_on_clauses.md)** | Avoid catches without on clauses. |
| **[avoid_catching_errors](rules/avoid_catching_errors.md)** | Don't explicitly catch Error or types that implement it. |
| **[avoid_classes_with_only_static_members](rules/avoid_classes_with_only_static_members.md)** | Avoid defining a class that contains only static members. |
| **[avoid_double_and_int_checks](rules/avoid_double_and_int_checks.md)** | Avoid double and int checks. |
| **[avoid_dynamic_calls](rules/avoid_dynamic_calls.md)** | Avoid method calls or property accesses on a "dynamic" target. |
| **[avoid_equals_and_hash_code_on_mutable_classes](rules/avoid_equals_and_hash_code_on_mutable_classes.md)** | Avoid overloading operator == and hashCode on classes not marked `@immutable`. |
| **[avoid_escaping_inner_quotes](rules/avoid_escaping_inner_quotes.md)** | Avoid escaping inner quotes by converting surrounding quotes. |
| **[avoid_field_initializers_in_const_classes](rules/avoid_field_initializers_in_const_classes.md)** | Avoid field initializers in const classes. |
| **[avoid_final_parameters](rules/avoid_final_parameters.md)** | Avoid final for parameter declarations. |
| **[avoid_implementing_value_types](rules/avoid_implementing_value_types.md)** | Don't implement classes that override `==`. |
| **[avoid_js_rounded_ints](rules/avoid_js_rounded_ints.md)** | Avoid JavaScript rounded ints. |
| **[avoid_multiple_declarations_per_line](rules/avoid_multiple_declarations_per_line.md)** | Don't declare multiple variables on a single line. |
| **[avoid_positional_boolean_parameters](rules/avoid_positional_boolean_parameters.md)** | Avoid positional boolean parameters. |
| **[avoid_private_typedef_functions](rules/avoid_private_typedef_functions.md)** | Avoid private typedef functions. |
| **[avoid_redundant_argument_values](rules/avoid_redundant_argument_values.md)** | Avoid redundant argument values. |
| **[avoid_returning_null](rules/avoid_returning_null.md)** | Avoid returning null from members whose return type is bool, double, int, or num. `deprecated` |
| **[avoid_returning_null_for_future](rules/avoid_returning_null_for_future.md)** | Avoid returning null for Future. `deprecated` |
| **[avoid_returning_this](rules/avoid_returning_this.md)** | Avoid returning this from methods just to enable a fluent interface. |
| **[avoid_setters_without_getters](rules/avoid_setters_without_getters.md)** | Avoid setters without getters. |
| **[avoid_slow_async_io](rules/avoid_slow_async_io.md)** | Avoid slow async `dart:io` methods. |
| **[avoid_type_to_string](rules/avoid_type_to_string.md)** | Avoid <Type>.toString() in production code since results may be minified. |
| **[avoid_types_on_closure_parameters](rules/avoid_types_on_closure_parameters.md)** | Avoid annotating types for function expression parameters. |
| **[avoid_unused_constructor_parameters](rules/avoid_unused_constructor_parameters.md)** | Avoid defining unused parameters in constructors. |
| **[avoid_void_async](rules/avoid_void_async.md)** | Avoid async functions that return void. |
| **[cancel_subscriptions](rules/cancel_subscriptions.md)** | Cancel instances of dart.async.StreamSubscription. |
| **[cascade_invocations](rules/cascade_invocations.md)** | Cascade consecutive method invocations on the same reference. |
| **[cast_nullable_to_non_nullable](rules/cast_nullable_to_non_nullable.md)** | Don't cast a nullable value to a non nullable type. |
| **[close_sinks](rules/close_sinks.md)** | Close instances of `dart.core.Sink`. |
| **[collection_methods_unrelated_type](rules/collection_methods_unrelated_type.md)** | Invocation of various collection methods with arguments of unrelated types. |
| **[combinators_ordering](rules/combinators_ordering.md)** | Sort combinator names alphabetically. |
| **[comment_references](rules/comment_references.md)** | Only reference in scope identifiers in doc comments. |
| **[conditional_uri_does_not_exist](rules/conditional_uri_does_not_exist.md)** | Missing conditional import. |
| **[dangling_library_doc_comments](rules/dangling_library_doc_comments.md)** | Attach library doc comments to library directives. |
| **[deprecated_consistency](rules/deprecated_consistency.md)** | Missing deprecated annotation. |
| **[diagnostic_describe_all_properties](rules/diagnostic_describe_all_properties.md)** | DO reference all public properties in debug methods. |
| **[directives_ordering](rules/directives_ordering.md)** | Adhere to Effective Dart Guide directives sorting conventions. |
| **[discarded_futures](rules/discarded_futures.md)** | Don't invoke asynchronous functions in non-async blocks. |
| **[do_not_use_environment](rules/do_not_use_environment.md)** | Do not use environment declared variables. |
| **[eol_at_end_of_file](rules/eol_at_end_of_file.md)** | Put a single newline at end of file. |
| **[flutter_style_todos](rules/flutter_style_todos.md)** | Use Flutter TODO format: // TODO(username): message, https://URL-to-issue. |
| **[implicit_call_tearoffs](rules/implicit_call_tearoffs.md)** | Explicitly tear-off `call` methods when using an object as a Function. |
| **[invalid_case_patterns](rules/invalid_case_patterns.md)** | Use case expressions that are valid in Dart 3.0. `experimental` |
| **[join_return_with_assignment](rules/join_return_with_assignment.md)** | Join return statement with assignment when possible. |
| **[leading_newlines_in_multiline_strings](rules/leading_newlines_in_multiline_strings.md)** | Start multiline strings with a newline. |
| **[library_annotations](rules/library_annotations.md)** | Attach library annotations to library directives. |
| **[lines_longer_than_80_chars](rules/lines_longer_than_80_chars.md)** | Avoid lines longer than 80 characters. |
| **[literal_only_boolean_expressions](rules/literal_only_boolean_expressions.md)** | Boolean expression composed only with literals. |
| **[missing_whitespace_between_adjacent_strings](rules/missing_whitespace_between_adjacent_strings.md)** | Missing whitespace between adjacent strings. |
| **[no_adjacent_strings_in_list](rules/no_adjacent_strings_in_list.md)** | Don't use adjacent strings in list. |
| **[no_default_cases](rules/no_default_cases.md)** | No default cases. `experimental` |
| **[no_runtimeType_toString](rules/no_runtimeType_toString.md)** | Avoid calling toString() on runtimeType. |
| **[noop_primitive_operations](rules/noop_primitive_operations.md)** | Noop primitive operations. |
| **[omit_local_variable_types](rules/omit_local_variable_types.md)** | Omit type annotations for local variables. |
| **[one_member_abstracts](rules/one_member_abstracts.md)** | Avoid defining a one-member abstract class when a simple function will do. |
| **[only_throw_errors](rules/only_throw_errors.md)** | Only throw instances of classes extending either Exception or Error. |
| **[package_api_docs](rules/package_api_docs.md)** | Provide doc comments for all public APIs. |
| **[parameter_assignments](rules/parameter_assignments.md)** | Don't reassign references to parameters of functions or methods. |
| **[prefer_asserts_in_initializer_lists](rules/prefer_asserts_in_initializer_lists.md)** | Prefer putting asserts in initializer lists. |
| **[prefer_asserts_with_message](rules/prefer_asserts_with_message.md)** | Prefer asserts with message. |
| **[prefer_constructors_over_static_methods](rules/prefer_constructors_over_static_methods.md)** | Prefer defining constructors instead of static methods to create instances. |
| **[prefer_double_quotes](rules/prefer_double_quotes.md)** | Prefer double quotes where they won't require escape sequences. |
| **[prefer_expression_function_bodies](rules/prefer_expression_function_bodies.md)** | Use => for short members whose body is a single return statement. |
| **[prefer_final_in_for_each](rules/prefer_final_in_for_each.md)** | Prefer final in for-each loop variable if reference is not reassigned. |
| **[prefer_final_locals](rules/prefer_final_locals.md)** | Prefer final for variable declarations if they are not reassigned. |
| **[prefer_final_parameters](rules/prefer_final_parameters.md)** | Prefer final for parameter declarations if they are not reassigned. |
| **[prefer_foreach](rules/prefer_foreach.md)** | Use `forEach` to only apply a function to all the elements. |
| **[prefer_if_elements_to_conditional_expressions](rules/prefer_if_elements_to_conditional_expressions.md)** | Prefer if elements to conditional expressions where possible. |
| **[prefer_int_literals](rules/prefer_int_literals.md)** | Prefer int literals over double literals. |
| **[prefer_mixin](rules/prefer_mixin.md)** | Prefer using mixins. |
| **[prefer_null_aware_method_calls](rules/prefer_null_aware_method_calls.md)** | Prefer null aware method calls. |
| **[prefer_relative_imports](rules/prefer_relative_imports.md)** | Prefer relative imports for files in `lib/`. |
| **[prefer_single_quotes](rules/prefer_single_quotes.md)** | Only use double quotes for strings containing single quotes. |
| **[public_member_api_docs](rules/public_member_api_docs.md)** | Document all public members. |
| **[require_trailing_commas](rules/require_trailing_commas.md)** | Use trailing commas for all function calls and declarations. |
| **[secure_pubspec_urls](rules/secure_pubspec_urls.md)** | Use secure urls in `pubspec.yaml`. |
| **[sized_box_shrink_expand](rules/sized_box_shrink_expand.md)** | Use SizedBox shrink and expand named constructors. |
| **[sort_constructors_first](rules/sort_constructors_first.md)** | Sort constructor declarations before other members. |
| **[sort_pub_dependencies](rules/sort_pub_dependencies.md)** | Sort pub dependencies alphabetically. |
| **[sort_unnamed_constructors_first](rules/sort_unnamed_constructors_first.md)** | Sort unnamed constructor declarations first. |
| **[test_types_in_equals](rules/test_types_in_equals.md)** | Test type arguments in operator ==(Object other). |
| **[throw_in_finally](rules/throw_in_finally.md)** | Avoid `throw` in finally block. |
| **[tighten_type_of_initializing_formals](rules/tighten_type_of_initializing_formals.md)** | Tighten type of initializing formal. |
| **[type_annotate_public_apis](rules/type_annotate_public_apis.md)** | Type annotate public APIs. |
| **[unawaited_futures](rules/unawaited_futures.md)** | `Future` results in `async` function bodies must be `await`ed or marked `unawaited` using `dart:async`. |
| **[unnecessary_await_in_return](rules/unnecessary_await_in_return.md)** | Unnecessary await keyword in return. |
| **[unnecessary_breaks](rules/unnecessary_breaks.md)** | Don't use explicit `break`s when a break is implied. |
| **[unnecessary_final](rules/unnecessary_final.md)** | Don't use `final` for local variables. |
| **[unnecessary_lambdas](rules/unnecessary_lambdas.md)** | Don't create a lambda when a tear-off will do. |
| **[unnecessary_library_directive](rules/unnecessary_library_directive.md)** | Avoid library directives unless they have documentation comments or annotations. |
| **[unnecessary_null_aware_operator_on_extension_on_nullable](rules/unnecessary_null_aware_operator_on_extension_on_nullable.md)** | Unnecessary null aware operator on extension on a nullable type. |
| **[unnecessary_null_checks](rules/unnecessary_null_checks.md)** | Unnecessary null checks. `experimental` |
| **[unnecessary_parenthesis](rules/unnecessary_parenthesis.md)** | Unnecessary parentheses can be removed. |
| **[unnecessary_raw_strings](rules/unnecessary_raw_strings.md)** | Unnecessary raw string. |
| **[unnecessary_statements](rules/unnecessary_statements.md)** | Avoid using unnecessary statements. |
| **[unnecessary_to_list_in_spreads](rules/unnecessary_to_list_in_spreads.md)** | Unnecessary toList() in spreads. |
| **[unreachable_from_main](rules/unreachable_from_main.md)** | Unreachable top-level members in executable libraries. `experimental` |
| **[unsafe_html](rules/unsafe_html.md)** | Avoid unsafe HTML APIs. |
| **[use_colored_box](rules/use_colored_box.md)** | Use `ColoredBox`. |
| **[use_decorated_box](rules/use_decorated_box.md)** | Use `DecoratedBox`. |
| **[use_enums](rules/use_enums.md)** | Use enums rather than classes that behave like enums. |
| **[use_if_null_to_convert_nulls_to_bools](rules/use_if_null_to_convert_nulls_to_bools.md)** | Use if-null operators to convert nulls to bools. |
| **[use_is_even_rather_than_modulo](rules/use_is_even_rather_than_modulo.md)** | Prefer intValue.isOdd/isEven instead of checking the result of % 2. |
| **[use_late_for_private_fields_and_variables](rules/use_late_for_private_fields_and_variables.md)** | Use late for private members with a non-nullable type. `experimental` |
| **[use_named_constants](rules/use_named_constants.md)** | Use predefined named constants. |
| **[use_raw_strings](rules/use_raw_strings.md)** | Use raw string to avoid escapes. |
| **[use_setters_to_change_properties](rules/use_setters_to_change_properties.md)** | Use a setter for operations that conceptually change a property. |
| **[use_string_buffers](rules/use_string_buffers.md)** | Use string buffers to compose strings. |
| **[use_string_in_part_of_directives](rules/use_string_in_part_of_directives.md)** | Use string in part of directives. |
| **[use_super_parameters](rules/use_super_parameters.md)** | Use super-initializer parameters where possible. `experimental` |
| **[use_test_throws_matchers](rules/use_test_throws_matchers.md)** | Use throwsA matcher instead of fail(). |
| **[use_to_and_as_if_applicable](rules/use_to_and_as_if_applicable.md)** | Start the name of the method with to/_to or as/_as if applicable. |

## Removed Rules

The following rules are no longer included in the linter.

| Rule | Description |
| --- | --- |
| **[avoid_as](rules/avoid_as.md)** | Avoid using `as`. `removed` |
| **[enable_null_safety](rules/enable_null_safety.md)** | Do use sound null safety. `removed` |
| **[invariant_booleans](rules/invariant_booleans.md)** | Conditions should not unconditionally evaluate to `true` or to `false`. `removed` |
| **[prefer_bool_in_asserts](rules/prefer_bool_in_asserts.md)** | Prefer using a boolean as the assert condition. `removed` |
| **[super_goes_last](rules/super_goes_last.md)** | Place the `super` call last in a constructor initialization list. `removed` |
