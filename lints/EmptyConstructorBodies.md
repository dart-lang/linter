From the [style guide] (https://www.dartlang.org/articles/style-guide/):

**DO** use ```;``` instead of ```{}``` for empty constructor bodies.

In Dart, a constructor with an empty body can be terminated with just a semicolon. This is required for const constructors. For consistency and brevity, other constructors should also do this.

**GOOD:**
```
class Point { 
  int x, y; 
  Point(this.x, this.y);
}
```

**BAD:**
```
class Point { 
  int x, y;
  Point(this.x, this.y) {}
}
```
