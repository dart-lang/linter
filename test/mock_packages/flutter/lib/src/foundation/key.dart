abstract class Key {
  const factory Key(String value) = ValueKey<String>;

  const Key._();
}

abstract class LocalKey extends Key {
  const LocalKey() : super._();
}

class ValueKey<T> extends LocalKey {
  final T value;

  const ValueKey(this.value);
}
