As visible in `google.analysis_options`, not all available lint rules are
suggested for new Google projects.

Instead, a strict *subset* of the rules have been curated based on being:

- Useful: A strongly defined purpose (prevents errors, enforces style)
- Effective: 0 false positives, does not create extra work for contributors
- Consistent: Does not conflict with the [style guide][style] or other lints

[style]: https://www.dartlang.org/guides/language/effective-dart/style

Some rules have good intentions, but would be difficult to consistently enforce
across all Google-owned packages in `https://github.com/dart-lang/*` or would
conflict with the spirit of the style guide - i.e. treating "consider" or
"prefer" as "must".

In general, all of the rules in the curated list would be safely enforcable
with a presubmit script on travis or another continious integration system. It
is **strongly not recommended** to enable any other lint rules in Dart-owned
packages.
