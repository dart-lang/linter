library meta;

const Immutable immutable = const Immutable();

const _MustCallSuper mustCallSuper = const _MustCallSuper();

const _Protected protected = const _Protected();

const Required required = const Required();

class Immutable {
  final String reason;
  const Immutable([this.reason]);
}

class Required {
  final String reason;
  const Required([this.reason]);
}

class _MustCallSuper {
  const _MustCallSuper();
}

class _Protected {
  const _Protected();
}
