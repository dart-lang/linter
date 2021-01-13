// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test test/rule_test.dart -N avoid_dynamic_calls`

void explicitDynamicType(dynamic object) {
  object.foo(); // LINT
  object.bar; // LINT
}

void implicitDynamicType(object) {
  object.foo(); // LINT
  object.bar; // LINT
}

// This would likely not pass at runtime, but we're using it for inference only.
T genericType<T>() => null as T;

void inferredDynamicType() {
  var object = genericType();
  object.foo(); // LINT
  object.bar; // LINT
}

class Wrapper<T> {
  final T field;
  Wrapper(this.field);
}

void fieldDynamicType(Wrapper<dynamic> wrapper) {
  final field = wrapper.field;
  field.foo(); // LINT
  field.bar; // LINT
  wrapper.field(); // LINT
}

void cascadeExpressions(dynamic a, Wrapper<dynamic> b) {
  a..b; // LINT
  b..field; // OK
  b
    ..toString
    ..field.a() // LINT
    ..field.b; // LINT
}

void otherPropertyAccessOrCalls(dynamic a) {
  a(); // LINT
  a?.b; // LINT
  a!.b; // LINT
  a?.b(); // LINT
  a!.b(); // LINT
}

void functionExpressionInvocations(dynamic a(), Function b()) {
  a(); // OK
  a()(); // LINT
  b(); // OK
  b()(); // LINT
}

void typedFunctionButBasicallyDynamic(Function a, Wrapper<Function> b) {
  a(); // LINT
  b.field(); // LINT
}

void binaryExpressions(dynamic a, int b) {
  a + a; // LINT
  a + b; // LINT
  a > b; // LINT
  a < b; // LINT
  a ^ b; // LINT
  a | b; // LINT
  a & b; // LINT
  a % b; // LINT
  a / b; // LINT
  a ~/ b; // LINT
  a >> b; // LINT
  a << b; // LINT
  a || b; // LINT
  a && b; // LINT
  b + a; // OK; this is an implicit downcast, not a dynamic call
  a ?? b; // OK; this is a null comparison, not a dynamic call.
}

void equalityExpressions(dynamic a, dynamic b) {
  a == b; // LINT
  a == null; // OK, special cased.
  a != b; // LINT
  a != null; // OK.
}

void assngmentExpressions(dynamic a) {
  a += 1; // LINT
  a -= 1; // LINT
  a *= 1; // LINT
  a ^= 1; // LINT
  a /= 1; // LINT
  a &= 1; // LINT
  a |= 1; // LINT
  a ??= 1; // OK
}

void prefixExpressions(dynamic a, int b) {
  !a; // LINT
  -a; // LINT
  ++a; // LINT
  --a; // LINT
  ++b; // OK
  --b; // OK
}

void postfixExpressions(dynamic a, int b) {
  a!; // OK; this is not a dynamic call.
  a++; // LINT
  a--; // LINT
  b++; // OK
  b--; // OK
}

void indexExpressions(dynamic a) {
  a[1]; // LINT
  a[1] = 1; // LINT
  a = a[1]; // LINT
}
