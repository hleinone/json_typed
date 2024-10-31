/// An error about the value under [key] in a `JsonObject`.
///
/// The common type of every error a `JsonObject` getter throws.
abstract class JsonKeyError extends Error {
  /// The key the error is about.
  final String key;

  /// Creates an error about the value under [key].
  JsonKeyError(this.key);
}

/// An error for a key that is missing or holds a JSON null.
///
/// Thrown by the `get*` methods of `JsonObject` when no fallback is given.
class JsonKeyNotFoundError extends JsonKeyError {
  /// Creates an error for [key].
  JsonKeyNotFoundError(super.key);

  @override
  String toString() {
    return 'JsonKeyNotFoundError: Value for key "$key" is not found';
  }
}

/// An error for a value that is not of type [T].
///
/// Thrown by the `as*` getters of `JsonValue` and `JsonArray`, and by the object and array decoders for a
/// top-level value of another kind.
class JsonTypeError<T> extends Error {
  /// The rejected value.
  final dynamic value;

  /// Creates an error for the rejected [value].
  JsonTypeError(this.value);

  @override
  String toString() {
    return 'JsonTypeError: Value "$value" is not of type $T';
  }
}

/// An error for a value under [key] that is not of type [T].
///
/// Thrown by the `get*` methods of `JsonObject`. Caught by both `on JsonTypeError` and `on JsonKeyError`.
class JsonKeyTypeError<T> extends JsonTypeError<T> implements JsonKeyError {
  @override
  final String key;

  /// Creates an error for the rejected [value] under [key].
  JsonKeyTypeError(this.key, super.value);

  @override
  String toString() {
    return 'JsonKeyTypeError: Value "$value" for key "$key" is not of type $T';
  }
}
