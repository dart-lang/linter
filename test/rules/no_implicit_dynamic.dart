takeInt(int i) {}
takeDynamic(dynamic i) {}
takeObject(Object i) {}

conditionals(implicitBool, bool explicitBool) {
  explicitBool ? 1 : 2;

  implicitBool //LINT
      ? 1 : 2;

  takeInt(explicitBool ? 1 : "2"); //LINT
}

methodCalls() {
  var implicitDynamic;
  dynamic explicitDynamic;

  takeDynamic(1);
  takeObject(1);
  takeInt(1);

  takeDynamic(implicitDynamic);
  takeObject(implicitDynamic);
  takeInt(implicitDynamic); //LINT

  takeDynamic(explicitDynamic);
  takeObject(explicitDynamic);
  takeInt(explicitDynamic);
}

class Foo {
  var implicitDynamic;
  dynamic explicitDynamic;
  int i;
}

assignments() {
  Foo newFoo() => new Foo();
  int i;
  var f = newFoo();

  // Exercice prefixed identifiers path:
  f.i = f.i;
  f.i = f.implicitDynamic; //LINT
  f.i = f.explicitDynamic;

  // Exercice property access path:
  f.i = newFoo().i;
  f.i = newFoo().implicitDynamic; //LINT
  f.i = newFoo().explicitDynamic;

  i = f.i;
  i = f.implicitDynamic; //LINT
  i = f.explicitDynamic;
}

vars(implicitDynamic, dynamic explicitDynamic) {
  implicitDynamic.foo; //LINT
  implicitDynamic?.foo; //LINT
  implicitDynamic.foo(); //LINT
  implicitDynamic?.foo(); //LINT
  implicitDynamic['foo']; //LINT
  implicitDynamic.toString();
  implicitDynamic.runtimeType;
  implicitDynamic.hashCode;

  (implicitDynamic as dynamic).foo;

  explicitDynamic.foo;
  explicitDynamic.foo();
  explicitDynamic['foo'];
  explicitDynamic.toString();
  explicitDynamic.runtimeType;
  explicitDynamic.hashCode;
}

operators(implicitDynamic, dynamic explicitDynamic) {
  implicitDynamic + 1; //LINT
  implicitDynamic * 1; //LINT

  explicitDynamic + 1;
  explicitDynamic + null;

  // int.operator+ expects an int parameter:
  1 + implicitDynamic; //LINT
  1 + explicitDynamic;
}

cascades() {
  var implicitDynamic;
  implicitDynamic
      ..foo //LINT
      ..foo() //LINT
      ..['foo'] //LINT
      ..toString()
      ..runtimeType
      ..hashCode;
}

dynamicMethods() {
  trim(s) =>
      s.trim(); //LINT
  var s = trim(1)
      .toUpperCase(); //LINT

  implicit() {}
  implicit()
    .x //LINT
    .y;

  dynamic explicit() {}
  explicit().x;
}

chaining() {
  var x;
  // Only report the first implicit dynamic in a chain:
  x
    .y //LINT
    .z
    .w;

  dynamic y;
  // Calling an explicit dynamic is okay...
  y.z;
  y.z();
  y['z'];
  // ... but returns an implicit dynamic.
  y.z.w; //LINT
  y.z().w; //LINT
  y['z'].w; //LINT
}
