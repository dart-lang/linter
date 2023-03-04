# Rule prefer_adjacent_string_concatenation

`flutter` `style` `stable` 

## Description

**DO** use adjacent strings to concatenate string literals.

**BAD:**
```dart
raiseAlarm(
    'ERROR: Parts of the spaceship are on fire. Other ' +
    'parts are overrun by martians. Unclear which are which.');
```

**GOOD:**
```dart
raiseAlarm(
    'ERROR: Parts of the spaceship are on fire. Other '
    'parts are overrun by martians. Unclear which are which.');
```
