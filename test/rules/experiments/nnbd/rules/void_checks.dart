import 'dart:async';

void emptyFunctionExpressionReturningFutureOrVoid(FutureOr<void> Function() f) {
  f = () {}; // OK
}
