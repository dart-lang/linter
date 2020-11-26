# Linter for Dart

## Lint Rules

[Using the Linter](https://dart.dev/guides/language/analysis-options#enabling-linter-rules)

## Supported Lint Rules

This list is auto-generated from our sources.

Rules are organized into familiar rule groups.

- **errors** - Possible coding errors.

- **style** - Matters of style, largely derived from the official Dart Style Guide.

- **pub** - Pub-related rules.

In addition, rules can be further distinguished by *maturity*.  Unqualified
rules are considered stable, while others may be marked **experimental**
to indicate that they are under review.  Lints that are marked as **deprecated**
should not be used and are subject to removal in future Linter releases.

Rules can be selectively enabled in the analyzer using
[analysis options](https://pub.dev/packages/analyzer)
or through an
[analysis options file](https://dart.dev/guides/language/analysis-options#the-analysis-options-file). 

* **An auto-generated list enabling all options is provided [here](options/options.html).** 

As some lints may contradict each other, only a subset of these will be
enabled in practice, but this list should provide a convenient jumping-off point.

Many lints are included in various predefined rulesets:

* [pedantic](https://github.com/dart-lang/pedantic) for rules enforced internally at Google
* [effective_dart](https://github.com/tenhobi/effective_dart) for rules corresponding to the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
* [flutter](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml) for rules used in <code>flutter analyze</code>

Rules included in these rulesets are badged in the documentation below.

These rules are under active development.  Feedback is
[welcome](https://github.com/dart-lang/linter/issues)!


## Error Rules

**[always_use_package_imports](always_use_package_imports.md)** - Avoid relative imports for files in `lib/`.

**[avoid_empty_else](avoid_empty_else.md)** - Avoid empty else statements.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[avoid_print](avoid_print.md)** - Avoid `print` calls in production code.

**[avoid_relative_lib_imports](avoid_relative_lib_imports.md)** - Avoid relative imports for files in `lib/`.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_returning_null_for_future](avoid_returning_null_for_future.md)** - Avoid returning null for Future.

**[avoid_slow_async_io](avoid_slow_async_io.md)** - Avoid slow async `dart:io` methods.

**[avoid_type_to_string](avoid_type_to_string.md)** - Avoid <Type>.toString() in production code since results may be minified.

**[avoid_types_as_parameter_names](avoid_types_as_parameter_names.md)** - Avoid types as parameter names.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[avoid_web_libraries_in_flutter](avoid_web_libraries_in_flutter.md)** - Avoid using web-only libraries outside Flutter web plugin packages.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)

**[cancel_subscriptions](cancel_subscriptions.md)** - Cancel instances of dart.async.StreamSubscription.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)

**[close_sinks](close_sinks.md)** - Close instances of `dart.core.Sink`.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)

**[comment_references](comment_references.md)** - Only reference in scope identifiers in doc comments.

**[control_flow_in_finally](control_flow_in_finally.md)** - Avoid control flow in finally blocks.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)

**[diagnostic_describe_all_properties](diagnostic_describe_all_properties.md)** - DO reference all public properties in debug methods.

**[empty_statements](empty_statements.md)** - Avoid empty statements.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)

**[hash_and_equals](hash_and_equals.md)** - Always override `hashCode` if overriding `==`.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[invariant_booleans](invariant_booleans.md)** - Conditions should not unconditionally evaluate to `true` or to `false`.

**[iterable_contains_unrelated_type](iterable_contains_unrelated_type.md)** - Invocation of Iterable<E>.contains with references of unrelated types.

**[list_remove_unrelated_type](list_remove_unrelated_type.md)** - Invocation of `remove` with references of unrelated types.

**[literal_only_boolean_expressions](literal_only_boolean_expressions.md)** - Boolean expression composed only with literals.

**[no_adjacent_strings_in_list](no_adjacent_strings_in_list.md)** - Don't use adjacent strings in list.

**[no_duplicate_case_values](no_duplicate_case_values.md)** - Don't use more than one case with same value.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[no_logic_in_create_state](no_logic_in_create_state.md)** - Don't put any logic in createState.

**[prefer_relative_imports](prefer_relative_imports.md)** - Prefer relative imports for files in `lib/`.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_void_to_null](prefer_void_to_null.md)** - Don't use the Null type, unless you are positive that you don't want void.

**[test_types_in_equals](test_types_in_equals.md)** - Test type arguments in operator ==(Object other).
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)

**[throw_in_finally](throw_in_finally.md)** - Avoid `throw` in finally block.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)

**[unnecessary_statements](unnecessary_statements.md)** - Avoid using unnecessary statements.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)

**[unrelated_type_equality_checks](unrelated_type_equality_checks.md)** - Equality operator `==` invocation with references of unrelated types.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[unsafe_html](unsafe_html.md)** - Avoid unsafe HTML APIs.

**[use_key_in_widget_constructors](use_key_in_widget_constructors.md)** - Use key in widget constructors.

**[valid_regexps](valid_regexps.md)** - Use valid regular expression syntax.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

## Style Rules

**[always_declare_return_types](always_declare_return_types.md)** - Declare method return types.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[always_put_control_body_on_new_line](always_put_control_body_on_new_line.md)** - Separate the control structure expression from its statement.

**[always_put_required_named_parameters_first](always_put_required_named_parameters_first.md)** - Put @required named parameters first.

**[always_require_non_null_named_parameters](always_require_non_null_named_parameters.md)** - Specify `@required` on named parameters without defaults.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[always_specify_types](always_specify_types.md)** - Specify type annotations.

**[annotate_overrides](annotate_overrides.md)** - Annotate overridden members.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[avoid_annotating_with_dynamic](avoid_annotating_with_dynamic.md)** - Avoid annotating with dynamic when not required.

**[avoid_as](avoid_as.md)** - Avoid using `as`.

**[avoid_bool_literals_in_conditional_expressions](avoid_bool_literals_in_conditional_expressions.md)** - Avoid bool literals in conditional expressions.

**[avoid_catches_without_on_clauses](avoid_catches_without_on_clauses.md)** - Avoid catches without on clauses.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_catching_errors](avoid_catching_errors.md)** - Don't explicitly catch Error or types that implement it.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_classes_with_only_static_members](avoid_classes_with_only_static_members.md)** - Avoid defining a class that contains only static members.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_double_and_int_checks](avoid_double_and_int_checks.md)** - Avoid double and int checks.

**[avoid_escaping_inner_quotes](avoid_escaping_inner_quotes.md)** - Avoid escaping inner quotes by converting surrounding quotes.

**[avoid_field_initializers_in_const_classes](avoid_field_initializers_in_const_classes.md)** - Avoid field initializers in const classes.

**[avoid_function_literals_in_foreach_calls](avoid_function_literals_in_foreach_calls.md)** - Avoid using `forEach` with a function literal.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_implementing_value_types](avoid_implementing_value_types.md)** - Don't implement classes that override `==`.

**[avoid_init_to_null](avoid_init_to_null.md)** - Don't explicitly initialize variables to null.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_js_rounded_ints](avoid_js_rounded_ints.md)** - Avoid JavaScript rounded ints.

**[avoid_null_checks_in_equality_operators](avoid_null_checks_in_equality_operators.md)** - Don't check for null in custom == operators.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_equals_and_hash_code_on_mutable_classes](avoid_equals_and_hash_code_on_mutable_classes.md)** - Avoid overloading operator == and hashCode on classes not marked `@immutable`.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_positional_boolean_parameters](avoid_positional_boolean_parameters.md)** - Avoid positional boolean parameters.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_private_typedef_functions](avoid_private_typedef_functions.md)** - Avoid private typedef functions.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_redundant_argument_values](avoid_redundant_argument_values.md)** - Avoid redundant argument values.

**[avoid_renaming_method_parameters](avoid_renaming_method_parameters.md)** - Don't rename parameters of overridden methods.

**[avoid_returning_null](avoid_returning_null.md)** - Avoid returning null from members whose return type is bool, double, int, or num.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_returning_null_for_void](avoid_returning_null_for_void.md)** - Avoid returning null for void.

**[avoid_returning_this](avoid_returning_this.md)** - Avoid returning this from methods just to enable a fluent interface.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_return_types_on_setters](avoid_return_types_on_setters.md)** - Avoid return types on setters.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_setters_without_getters](avoid_setters_without_getters.md)** - Avoid setters without getters.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_shadowing_type_parameters](avoid_shadowing_type_parameters.md)** - Avoid shadowing type parameters.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[avoid_single_cascade_in_expression_statements](avoid_single_cascade_in_expression_statements.md)** - Avoid single cascade in expression statements.

**[avoid_types_on_closure_parameters](avoid_types_on_closure_parameters.md)** - Avoid annotating types for function expression parameters.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[avoid_unnecessary_containers](avoid_unnecessary_containers.md)** - Avoid unnecessary containers.

**[avoid_unused_constructor_parameters](avoid_unused_constructor_parameters.md)** - Avoid defining unused parameters in constructors.

**[avoid_void_async](avoid_void_async.md)** - Avoid async functions that return void.

**[await_only_futures](await_only_futures.md)** - Await only futures.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)

**[camel_case_extensions](camel_case_extensions.md)** - Name extensions using UpperCamelCase.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[camel_case_types](camel_case_types.md)** - Name types using UpperCamelCase.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[cascade_invocations](cascade_invocations.md)** - Cascade consecutive method invocations on the same reference.

**[cast_nullable_to_non_nullable](cast_nullable_to_non_nullable.md)** - Don't cast a nullable value to a non nullable type.

**[constant_identifier_names](constant_identifier_names.md)** - Prefer using lowerCamelCase for constant names.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[curly_braces_in_flow_control_structures](curly_braces_in_flow_control_structures.md)** - DO use curly braces for all flow control structures.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[directives_ordering](directives_ordering.md)** - Adhere to Effective Dart Guide directives sorting conventions.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[do_not_use_environment](do_not_use_environment.md)** - Do not use environment declared variables.

**[empty_catches](empty_catches.md)** - Avoid empty catch blocks.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[empty_constructor_bodies](empty_constructor_bodies.md)** - Use `;` instead of `{}` for empty constructor bodies.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[exhaustive_cases](exhaustive_cases.md)** - Define case clauses for all constants in enum-like classes.

**[file_names](file_names.md)** - Name source files using `lowercase_with_underscores`.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[flutter_style_todos](flutter_style_todos.md)** - Use Flutter TODO format: // TODO(username): message, https://URL-to-issue.

**[implementation_imports](implementation_imports.md)** - Don't import implementation files from another package.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[join_return_with_assignment](join_return_with_assignment.md)** - Join return statement with assignment when possible.

**[leading_newlines_in_multiline_strings](leading_newlines_in_multiline_strings.md)** - Start multiline strings with a newline.

**[library_names](library_names.md)** - Name libraries using `lowercase_with_underscores`.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[library_prefixes](library_prefixes.md)** - Use `lowercase_with_underscores` when specifying a library prefix.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[lines_longer_than_80_chars](lines_longer_than_80_chars.md)** - Avoid lines longer than 80 characters.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[missing_whitespace_between_adjacent_strings](missing_whitespace_between_adjacent_strings.md)** - Missing whitespace between adjacent strings.

**[no_default_cases](no_default_cases.md)** - No default cases.

**[non_constant_identifier_names](non_constant_identifier_names.md)** - Name non-constant identifiers using lowerCamelCase.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[no_runtimeType_toString](no_runtimeType_toString.md)** - Avoid calling toString() on runtimeType.

**[null_check_on_nullable_type_parameter](null_check_on_nullable_type_parameter.md)** - Don't use null check on a potentially nullable type parameter.

**[null_closures](null_closures.md)** - Do not pass `null` as an argument where a closure is expected.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[omit_local_variable_types](omit_local_variable_types.md)** - Omit type annotations for local variables.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[one_member_abstracts](one_member_abstracts.md)** - Avoid defining a one-member abstract class when a simple function will do.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[only_throw_errors](only_throw_errors.md)** - Only throw instances of classes extending either Exception or Error.

**[overridden_fields](overridden_fields.md)** - Don't override fields.

**[package_api_docs](package_api_docs.md)** - Provide doc comments for all public APIs.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[package_prefixed_library_names](package_prefixed_library_names.md)** - Prefix library names with the package name and a dot-separated path.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)

**[parameter_assignments](parameter_assignments.md)** - Don't reassign references to parameters of functions or methods.

**[prefer_adjacent_string_concatenation](prefer_adjacent_string_concatenation.md)** - Use adjacent strings to concatenate string literals.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_asserts_in_initializer_lists](prefer_asserts_in_initializer_lists.md)** - Prefer putting asserts in initializer list.

**[prefer_asserts_with_message](prefer_asserts_with_message.md)** - Prefer asserts with message.

**[prefer_bool_in_asserts](prefer_bool_in_asserts.md)** - Prefer using a boolean as the assert condition.

**[prefer_collection_literals](prefer_collection_literals.md)** - Use collection literals when possible.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_conditional_assignment](prefer_conditional_assignment.md)** - Prefer using `??=` over testing for null.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[prefer_const_constructors](prefer_const_constructors.md)** - Prefer const with constant constructors.

**[prefer_const_constructors_in_immutables](prefer_const_constructors_in_immutables.md)** - Prefer declaring const constructors on `@immutable` classes.

**[prefer_const_declarations](prefer_const_declarations.md)** - Prefer const over final for declarations.

**[prefer_const_literals_to_create_immutables](prefer_const_literals_to_create_immutables.md)** - Prefer const literals as parameters of constructors on @immutable classes.

**[prefer_constructors_over_static_methods](prefer_constructors_over_static_methods.md)** - Prefer defining constructors instead of static methods to create instances.

**[prefer_contains](prefer_contains.md)** - Use contains for `List` and `String` instances.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[prefer_double_quotes](prefer_double_quotes.md)** - Prefer double quotes where they won't require escape sequences.

**[prefer_equal_for_default_values](prefer_equal_for_default_values.md)** - Use `=` to separate a named parameter from its default value.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_expression_function_bodies](prefer_expression_function_bodies.md)** - Use => for short members whose body is a single return statement.

**[prefer_final_fields](prefer_final_fields.md)** - Private field could be final.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_final_in_for_each](prefer_final_in_for_each.md)** - Prefer final in for-each loop variable if reference is not reassigned.

**[prefer_final_locals](prefer_final_locals.md)** - Prefer final for variable declarations if they are not reassigned.

**[prefer_foreach](prefer_foreach.md)** - Use `forEach` to only apply a function to all the elements.

**[prefer_for_elements_to_map_fromIterable](prefer_for_elements_to_map_fromIterable.md)** - Prefer for elements when building maps from iterables.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[prefer_function_declarations_over_variables](prefer_function_declarations_over_variables.md)** - Use a function declaration to bind a function to a name.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_generic_function_type_aliases](prefer_generic_function_type_aliases.md)** - Prefer generic function type aliases.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_if_elements_to_conditional_expressions](prefer_if_elements_to_conditional_expressions.md)** - Prefer if elements to conditional expressions where possible.

**[prefer_if_null_operators](prefer_if_null_operators.md)** - Prefer using if null operators.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[prefer_initializing_formals](prefer_initializing_formals.md)** - Use initializing formals when possible.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_inlined_adds](prefer_inlined_adds.md)** - Inline list item declarations where possible.

**[prefer_interpolation_to_compose_strings](prefer_interpolation_to_compose_strings.md)** - Use interpolation to compose strings and values.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_int_literals](prefer_int_literals.md)** - Prefer int literals over double literals.

**[prefer_is_empty](prefer_is_empty.md)** - Use `isEmpty` for Iterables and Maps.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_is_not_empty](prefer_is_not_empty.md)** - Use `isNotEmpty` for Iterables and Maps.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_is_not_operator](prefer_is_not_operator.md)** - Prefer is! operator.

**[prefer_iterable_whereType](prefer_iterable_whereType.md)** - Prefer to use whereType on iterable.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_mixin](prefer_mixin.md)** - Prefer using mixins.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[prefer_null_aware_operators](prefer_null_aware_operators.md)** - Prefer using null aware operators.

**[prefer_single_quotes](prefer_single_quotes.md)** - Only use double quotes for strings containing single quotes.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[prefer_spread_collections](prefer_spread_collections.md)** - Use spread collections when possible.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[prefer_typing_uninitialized_variables](prefer_typing_uninitialized_variables.md)** - Prefer typing uninitialized variables and fields.

**[provide_deprecation_message](provide_deprecation_message.md)** - Provide a deprecation message, via @Deprecated("message").

**[public_member_api_docs](public_member_api_docs.md)** - Document all public members.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[recursive_getters](recursive_getters.md)** - Property getter recursively returns itself.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[sized_box_for_whitespace](sized_box_for_whitespace.md)** - SizedBox for whitespace.

**[slash_for_doc_comments](slash_for_doc_comments.md)** - Prefer using /// for doc comments.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[sort_child_properties_last](sort_child_properties_last.md)** - Sort child properties last in widget instance creations.

**[sort_constructors_first](sort_constructors_first.md)** - Sort constructor declarations before other members.

**[sort_unnamed_constructors_first](sort_unnamed_constructors_first.md)** - Sort unnamed constructor declarations first.

**[super_goes_last](super_goes_last.md)** - Place the `super` call last in a constructor initialization list.

**[tighten_type_of_initializing_formals](tighten_type_of_initializing_formals.md)** - Tighten type of initializing formal.

**[type_annotate_public_apis](type_annotate_public_apis.md)** - Type annotate public APIs.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[type_init_formals](type_init_formals.md)** - Don't type annotate initializing formals.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[unawaited_futures](unawaited_futures.md)** - `Future` results in `async` function bodies must be `await`ed or marked `unawaited` using `package:pedantic`.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[unnecessary_await_in_return](unnecessary_await_in_return.md)** - Unnecessary await keyword in return.

**[unnecessary_brace_in_string_interps](unnecessary_brace_in_string_interps.md)** - Avoid using braces in interpolation when not needed.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[unnecessary_const](unnecessary_const.md)** - Avoid const keyword.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[unnecessary_final](unnecessary_final.md)** - Don't use `final` for local variables.

**[unnecessary_new](unnecessary_new.md)** - Unnecessary new keyword.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[unnecessary_null_aware_assignments](unnecessary_null_aware_assignments.md)** - Avoid null in null-aware assignment.

**[unnecessary_null_in_if_null_operators](unnecessary_null_in_if_null_operators.md)** - Avoid using `null` in `if null` operators.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[unnecessary_getters_setters](unnecessary_getters_setters.md)** - Avoid wrapping fields in getters and setters just to be "safe".
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[unnecessary_lambdas](unnecessary_lambdas.md)** - Don't create a lambda when a tear-off will do.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[unnecessary_nullable_for_final_variable_declarations](unnecessary_nullable_for_final_variable_declarations.md)** - Use a non-nullable type for a final variable initialized with a non-nullable value.

**[unnecessary_null_checks](unnecessary_null_checks.md)** - Unnecessary null checks.

**[unnecessary_overrides](unnecessary_overrides.md)** - Don't override a method to do a super method invocation with the same parameters.

**[unnecessary_parenthesis](unnecessary_parenthesis.md)** - Unnecessary parenthesis can be removed.

**[unnecessary_raw_strings](unnecessary_raw_strings.md)** - Unnecessary raw string.

**[unnecessary_string_escapes](unnecessary_string_escapes.md)** - Remove unnecessary backslashes in strings.

**[unnecessary_string_interpolations](unnecessary_string_interpolations.md)** - Unnecessary string interpolation.

**[unnecessary_this](unnecessary_this.md)** - Don't access members with `this` unless avoiding shadowing.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[use_full_hex_values_for_flutter_colors](use_full_hex_values_for_flutter_colors.md)** - Prefer an 8-digit hexadecimal integer(0xFFFFFFFF) to instantiate Color.

**[use_function_type_syntax_for_parameters](use_function_type_syntax_for_parameters.md)** - Use generic function type syntax for parameters.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)

**[use_is_even_rather_than_modulo](use_is_even_rather_than_modulo.md)** - Prefer intValue.isOdd/isEven instead of checking the result of % 2.

**[use_late_for_private_fields_and_variables](use_late_for_private_fields_and_variables.md)** - Use late for private members with non-nullable type.

**[use_rethrow_when_possible](use_rethrow_when_possible.md)** - Use rethrow to rethrow a caught exception.
[![pedantic](style-pedantic.svg)](https://github.com/dart-lang/pedantic/#enabled-lints)
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[use_raw_strings](use_raw_strings.md)** - Use raw string to avoid escapes.

**[use_setters_to_change_properties](use_setters_to_change_properties.md)** - Use a setter for operations that conceptually change a property.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[use_string_buffers](use_string_buffers.md)** - Use string buffers to compose strings.

**[use_to_and_as_if_applicable](use_to_and_as_if_applicable.md)** - Start the name of the method with to/_to or as/_as if applicable.
[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

**[void_checks](void_checks.md)** - Don't assign to void.

## Pub Rules

**[package_names](package_names.md)** - Use `lowercase_with_underscores` for package names.
[![flutter](style-flutter.svg)](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/analysis_options_user.yaml)

**[sort_pub_dependencies](sort_pub_dependencies.md)** - Sort pub dependencies.

