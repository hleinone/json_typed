# json_typed

[![CI](https://github.com/hleinone/json_typed/actions/workflows/ci.yml/badge.svg)](https://github.com/hleinone/json_typed/actions/workflows/ci.yml)

Typed access to decoded JSON in Dart, without wrapper objects.

`JsonObject`, `JsonArray` and `JsonValue` are extension types over the maps, lists and values that `dart:convert` produces. Wrapping costs nothing at runtime. Every read returns the requested type or throws.

## Features

- Decoders for a top-level object, array or any value.
- Typed getters for strings, bools, ints, doubles, nested objects and arrays.
- `OrNull` variants that return `null` instead of throwing.
- Fallbacks for missing keys and JSON nulls that keep the type check.
- Errors that name the key, the rejected value and the expected type.

## Getting started

Requires Dart 3.3 or later.

```sh
dart pub add json_typed
```

## Usage

```dart
import 'package:json_typed/json_typed.dart';

final user = jsonDecodeObject('''
{
  "name": "Ann",
  "age": 30,
  "active": true,
  "nickname": null,
  "address": {"city": "Helsinki"},
  "tags": ["admin", "beta"]
}
''');

final name = user.getString('name'); // 'Ann'
final age = user.getInt('age'); // 30
final score = user.getDouble('age'); // 30.0, an int converts to a double
final nickname = user.getStringOrNull('nickname'); // null
final role = user.getString('role', or: 'member'); // 'member'
final city = user.getObject('address').getString('city'); // 'Helsinki'
final tags = user.getArray('tags').asStrings; // ['admin', 'beta']

for (final tag in user.getArray('tags')) {
  print(tag.asString);
}
```

### Top-level values

A JSON document holds one top-level value. Pick the decode function for the kind you expect:

- `jsonDecodeObject` returns a `JsonObject` and throws a `JsonTypeError` for a document of another kind.
- `jsonDecodeArray` returns a `JsonArray` and throws a `JsonTypeError` for a document of another kind.
- `jsonDecodeValue` returns a `JsonValue` for a document of any kind, including a bare string, number, bool or `null`.

All three throw a `FormatException` for malformed JSON.

```dart
final ids = jsonDecodeArray('[1, 2, 3]').asInts; // [1, 2, 3]
final count = jsonDecodeValue('42').asInt; // 42
```

### Numbers

JSON has one number type. `asDouble` and `getDouble` accept any number. `asInt` and `getInt` accept a number without a fraction, so `1`, `1.0` and `1e2` all read as ints on every platform, and `1.5` throws. On the web, numbers are JavaScript numbers: integers above 2^53 lose precision.

### Missing keys and nulls

The typed getters treat a missing key and a JSON null the same way. `containsKey` tells them apart. `getValue` returns a JSON null as a value, and `isNull` reports it, as it does for a value in an array, in `entries` or at the top level.

| Call                               | Result                        |
|------------------------------------|-------------------------------|
| `user.getString('role')`           | throws `JsonKeyNotFoundError` |
| `user.getStringOrNull('role')`     | `null`                        |
| `user.containsKey('nickname')`     | `true`                        |
| `user.containsKey('role')`         | `false`                       |
| `user.getValue('nickname').isNull` | `true`                        |

### Fallbacks

`or` covers absence only. A missing key and a JSON null return the fallback, and a value of another kind still throws. `getStringOrNull(key) ?? fallback` reads the same but also returns the fallback for a value of another kind.

| Call                                      | Result                    |
|-------------------------------------------|---------------------------|
| `user.getString('role', or: 'member')`    | `'member'`                |
| `user.getString('age', or: 'member')`     | throws `JsonKeyTypeError` |
| `user.getStringOrNull('age') ?? 'member'` | `'member'`                |

Use `or` when a wrong type is a bug you want to see. Use an `OrNull` getter when a wrong type should count as absent.

### Error handling

Every error the package throws itself is a `JsonTypeError`, a `JsonKeyError` or both. Malformed input throws a `FormatException` from `dart:convert`. Array access outside the array throws the same errors as a `List`.

| Error                  | Thrown by                                                         |
|------------------------|-------------------------------------------------------------------|
| `FormatException`      | the decode functions, on malformed JSON                           |
| `JsonTypeError<T>`     | `as*` getters and the object and array decoders                   |
| `JsonKeyNotFoundError` | `JsonObject` getters without a fallback, on missing key or null   |
| `JsonKeyTypeError<T>`  | `JsonObject` getters, on a value of another kind                  |
| `RangeError`           | `JsonArray` index operator, on an index outside the array         |
| `StateError`           | `Iterable` members such as `first` or `single`, on an empty array |

A value of mismatching type throws, even when a fallback is given.

```dart
try {
  user.getInt('name');
} on JsonKeyTypeError catch (error) {
  print(error); // JsonKeyTypeError: Value "Ann" for key "name" is not of type int
}
```

`JsonKeyTypeError` is both a `JsonTypeError` and a `JsonKeyError`, so:

- catch `JsonKeyError` for everything a `JsonObject` getter can throw,
- catch `JsonTypeError` for every type mismatch, wherever it happens,
- catch `FormatException` for malformed input.

For arrays, `dart:core` already has the `OrNull` forms: `elementAtOrNull`, `firstOrNull`, `lastOrNull` and `singleOrNull` return `null` instead of throwing.

The `Json*` errors, `RangeError` and `StateError` extend `Error`: they mean the input broke the shape the code expects. Use a fallback for a field that may be absent, an `OrNull` getter when a wrong type should also count as absent, and catch the errors at the boundary where you can report or recover.

## Releasing

Releases are published from GitHub Actions. pub.dev accepts publishing from push events in this repository with the tag pattern `v{{version}}`, and the `Publish` workflow refuses to publish when the tag and the pubspec version differ.

1. Set `version` in `pubspec.yaml` and add a `CHANGELOG.md` entry with the same version.
2. Commit, push to `main` and wait for the `CI` workflow to pass.
3. Tag the commit and push the tag:

   ```sh
   git tag v0.1.0 && git push origin v0.1.0
   ```

4. Check the `Publish` run in the Actions tab, then the package page on pub.dev.

The tag pattern skips pre-release versions such as `v0.2.0-dev`. Publish those by hand with `dart pub publish`. A published version can be retracted on pub.dev within seven days and never deleted.

## License

MIT
