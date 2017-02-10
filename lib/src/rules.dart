// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules;

import 'package:linter/src/analyzer.dart';
import 'package:linter/src/rules/always_declare_return_types.dart';
import 'package:linter/src/rules/always_specify_types.dart';
import 'package:linter/src/rules/annotate_overrides.dart';
import 'package:linter/src/rules/avoid_as.dart';
import 'package:linter/src/rules/avoid_empty_else.dart';
import 'package:linter/src/rules/avoid_init_to_null.dart';
import 'package:linter/src/rules/avoid_return_types_on_setters.dart';
import 'package:linter/src/rules/avoid_slow_async_io.dart';
import 'package:linter/src/rules/await_only_futures.dart';
import 'package:linter/src/rules/camel_case_types.dart';
import 'package:linter/src/rules/cancel_subscriptions.dart';
import 'package:linter/src/rules/cascade_invocations.dart';
import 'package:linter/src/rules/close_sinks.dart';
import 'package:linter/src/rules/comment_references.dart';
import 'package:linter/src/rules/constant_identifier_names.dart';
import 'package:linter/src/rules/control_flow_in_finally.dart';
import 'package:linter/src/rules/empty_catches.dart';
import 'package:linter/src/rules/empty_constructor_bodies.dart';
import 'package:linter/src/rules/empty_statements.dart';
import 'package:linter/src/rules/hash_and_equals.dart';
import 'package:linter/src/rules/implementation_imports.dart';
import 'package:linter/src/rules/invariant_booleans.dart';
import 'package:linter/src/rules/iterable_contains_unrelated_type.dart';
import 'package:linter/src/rules/library_names.dart';
import 'package:linter/src/rules/library_prefixes.dart';
import 'package:linter/src/rules/list_remove_unrelated_type.dart';
import 'package:linter/src/rules/literal_only_boolean_expressions.dart';
import 'package:linter/src/rules/no_adjacent_strings_in_list.dart';
import 'package:linter/src/rules/no_duplicate_case_values.dart';
import 'package:linter/src/rules/non_constant_identifier_names.dart';
import 'package:linter/src/rules/one_member_abstracts.dart';
import 'package:linter/src/rules/only_throw_errors.dart';
import 'package:linter/src/rules/overridden_fields.dart';
import 'package:linter/src/rules/package_api_docs.dart';
import 'package:linter/src/rules/package_prefixed_library_names.dart';
import 'package:linter/src/rules/parameter_assignments.dart';
import 'package:linter/src/rules/prefer_const_constructors.dart';
import 'package:linter/src/rules/prefer_contains.dart';
import 'package:linter/src/rules/prefer_final_fields.dart';
import 'package:linter/src/rules/prefer_final_locals.dart';
import 'package:linter/src/rules/prefer_is_empty.dart';
import 'package:linter/src/rules/prefer_is_not_empty.dart';
import 'package:linter/src/rules/pub/package_names.dart';
import 'package:linter/src/rules/public_member_api_docs.dart';
import 'package:linter/src/rules/recursive_getter.dart';
import 'package:linter/src/rules/slash_for_doc_comments.dart';
import 'package:linter/src/rules/sort_constructors_first.dart';
import 'package:linter/src/rules/sort_unnamed_constructors_first.dart';
import 'package:linter/src/rules/super_goes_last.dart';
import 'package:linter/src/rules/test_types_in_equals.dart';
import 'package:linter/src/rules/throw_in_finally.dart';
import 'package:linter/src/rules/type_annotate_public_apis.dart';
import 'package:linter/src/rules/type_init_formals.dart';
import 'package:linter/src/rules/unawaited_futures.dart';
import 'package:linter/src/rules/unnecessary_brace_in_string_interp.dart';
import 'package:linter/src/rules/unnecessary_getters_setters.dart';
import 'package:linter/src/rules/unnecessary_null_aware_assignment.dart';
import 'package:linter/src/rules/unnecessary_null_in_if_null_operator.dart';
import 'package:linter/src/rules/unrelated_type_equality_checks.dart';
import 'package:linter/src/rules/valid_regexps.dart';

void registerLintRules() {
  Analyzer.facade
    ..register(new AlwaysDeclareReturnTypes())
    ..register(new AlwaysSpecifyTypes())
    ..register(new AnnotateOverrides())
    ..register(new AvoidAs())
    ..register(new AvoidEmptyElse())
    ..register(new AvoidInitToNull())
    ..register(new AvoidReturnTypesOnSetters())
    ..register(new AvoidSlowAsyncIo())
    ..register(new AwaitOnlyFutures())
    ..registerDefault(new CamelCaseTypes())
    ..register(new CancelSubscriptions())
    ..register(new CascadeInvocations())
    ..register(new CloseSinks())
    ..register(new CommentReferences())
    ..register(new ControlFlowInFinally())
    ..registerDefault(new ConstantIdentifierNames())
    ..register(new EmptyCatches())
    ..registerDefault(new EmptyConstructorBodies())
    ..register(new EmptyStatements())
    ..register(new HashAndEquals())
    ..register(new ImplementationImports())
    ..register(new InvariantBooleans())
    ..register(new IterableContainsUnrelatedType())
    ..registerDefault(new LibraryNames())
    ..registerDefault(new LibraryPrefixes())
    ..register(new ListRemoveUnrelatedType())
    ..register(new LiteralOnlyBooleanExpressions())
    ..register(new NoAdjacentStringsInList())
    ..register(new NoDuplicateCaseValues())
    ..registerDefault(new NonConstantIdentifierNames())
    ..registerDefault(new OneMemberAbstracts())
    ..register(new OnlyThrowErrors())
    ..register(new OverriddenFields())
    ..register(new PackageApiDocs())
    ..register(new PackagePrefixedLibraryNames())
    ..register(new ParameterAssignments())
    ..register(new PreferConstConstructors())
    ..register(new PreferContainsOverIndexOf())
    ..register(new PreferFinalFields())
    ..register(new PreferFinalLocals())
    ..register(new PreferIsEmpty())
    ..register(new PreferIsNotEmpty())
    ..register(new PublicMemberApiDocs())
    ..register(new PubPackageNames())
    ..register(new RecursiveGetter())
    ..registerDefault(new SlashForDocComments())
    ..register(new SortConstructorsFirst())
    ..register(new SortUnnamedConstructorsFirst())
    ..registerDefault(new SuperGoesLast())
    ..register(new TestTypesInEquals())
    ..register(new ThrowInFinally())
    ..register(new TypeAnnotatePublicApis())
    ..registerDefault(new TypeInitFormals())
    ..register(new UnawaitedFutures())
    ..registerDefault(new UnnecessaryBraceInStringInterp())
    ..registerDefault(new UnnecessaryNullAwareAssignment())
    ..registerDefault(new UnnecessaryNullInIfNullOperator())
    // Disabled pending fix: https://github.com/dart-lang/linter/issues/35
    //..register(new UnnecessaryGetters())
    ..register(new UnnecessaryGettersSetters())
    ..register(new UnrelatedTypeEqualityChecks())
    ..register(new ValidRegExps());
}
