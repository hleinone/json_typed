import 'json_errors.dart';
import 'json_array.dart';
import 'json_value.dart';

/// A decoded JSON object.
///
/// The typed `get*` methods return the value under a key. A missing key and a JSON null return the `or`
/// fallback when it is given and throw a [JsonKeyNotFoundError] otherwise. A value of another kind throws a
/// [JsonKeyTypeError], even when `or` is given. The `get*OrNull` methods return null instead of throwing.
/// [getValue] returns a JSON null as a [JsonValue], and [containsKey] tells a missing key from a JSON null.
extension type const JsonObject(Map<String, JsonValue> _value) {
  /// The value under [key], or null for a missing key and a JSON null.
  JsonValue? operator [](String key) => _value[key];

  /// Whether [key] is present, including a key that holds a JSON null.
  bool containsKey(String key) => _value.containsKey(key);

  /// Returns the value under [key], including a JSON null. Throws a [JsonKeyNotFoundError] for a missing key.
  JsonValue getValue(String key) {
    // A stored JSON null is a null JsonValue. The cast passes it through, where `!` would throw.
    if (_value.containsKey(key)) return _value[key] as JsonValue;
    throw JsonKeyNotFoundError(key);
  }

  /// Returns the value under [key], or null for a missing key and a JSON null.
  JsonValue? getValueOrNull(String key) => this[key];

  /// Returns the value under [key] as a [String].
  String getString(String key, {String? or}) => _get(key, or, (value) => value.asStringOrNull);

  /// Returns the value under [key] as a [String], or null when [getString] would throw.
  String? getStringOrNull(String key) => this[key]?.asStringOrNull;

  /// Returns the value under [key] as a [bool].
  bool getBool(String key, {bool? or}) => _get(key, or, (value) => value.asBoolOrNull);

  /// Returns the value under [key] as a [bool], or null when [getBool] would throw.
  bool? getBoolOrNull(String key) => this[key]?.asBoolOrNull;

  /// Returns the value under [key] as an [int]. A [double] with an integral value converts, and a fraction throws.
  int getInt(String key, {int? or}) => _get(key, or, (value) => value.asIntOrNull);

  /// Returns the value under [key] as an [int], or null when [getInt] would throw.
  int? getIntOrNull(String key) => this[key]?.asIntOrNull;

  /// Returns the value under [key] as a [double]. An [int] converts to a [double].
  double getDouble(String key, {double? or}) => _get(key, or, (value) => value.asDoubleOrNull);

  /// Returns the value under [key] as a [double], or null when [getDouble] would throw.
  double? getDoubleOrNull(String key) => this[key]?.asDoubleOrNull;

  /// Returns the value under [key] as a [JsonObject].
  JsonObject getObject(String key, {JsonObject? or}) => _get(key, or, (value) => value.asObjectOrNull);

  /// Returns the value under [key] as a [JsonObject], or null when [getObject] would throw.
  JsonObject? getObjectOrNull(String key) => this[key]?.asObjectOrNull;

  /// Returns the value under [key] as a [JsonArray].
  JsonArray getArray(String key, {JsonArray? or}) => _get(key, or, (value) => value.asArrayOrNull);

  /// Returns the value under [key] as a [JsonArray], or null when [getArray] would throw.
  JsonArray? getArrayOrNull(String key) => this[key]?.asArrayOrNull;

  /// The entries in document order, including entries whose value is null.
  Iterable<MapEntry<String, JsonValue>> get entries => _value.entries;

  T _get<T>(String key, T? or, T? Function(JsonValue value) convert) {
    final value = this[key];
    if (value == null) return or ?? (throw JsonKeyNotFoundError(key));
    // this[key] maps a JSON null to null, so a null from convert means the value has another type.
    return convert(value) ?? (throw JsonKeyTypeError<T>(key, value));
  }
}
