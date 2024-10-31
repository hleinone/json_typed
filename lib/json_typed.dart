/// Typed access to decoded JSON without wrapper objects.
///
/// [JsonObject], [JsonArray] and [JsonValue] are extension types over the maps, lists and values that
/// `dart:convert` produces. Wrapping costs nothing at runtime.
///
/// Every error the package throws itself is a [JsonTypeError], a [JsonKeyError] or both. Malformed input throws
/// a [FormatException] from `dart:convert`, and array access outside the array throws a [RangeError] or a
/// [StateError], as a [List] does.
library;

import 'dart:convert';

import 'src/json_array.dart';
import 'src/json_errors.dart';
import 'src/json_object.dart';
import 'src/json_value.dart';

export 'src/json_object.dart';
export 'src/json_value.dart';
export 'src/json_array.dart';
export 'src/json_errors.dart';

/// Decodes [source] as a JSON value of any kind, including a top-level string, number, bool or null.
///
/// Throws a [FormatException] for malformed JSON.
JsonValue jsonDecodeValue(String source) => JsonValue(jsonDecode(source));

/// Decodes [source] as a JSON object.
///
/// Throws a [FormatException] for malformed JSON and a [JsonTypeError] when the top-level value is not an object.
JsonObject jsonDecodeObject(String source) => jsonDecodeValue(source).asObject;

/// Decodes [source] as a JSON array.
///
/// Throws a [FormatException] for malformed JSON and a [JsonTypeError] when the top-level value is not an array.
JsonArray jsonDecodeArray(String source) => jsonDecodeValue(source).asArray;
