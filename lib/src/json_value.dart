import 'json_errors.dart';
import 'json_array.dart';
import 'json_object.dart';

/// A decoded JSON value of any kind.
///
/// The `as*` getters return the value as the requested type and throw a [JsonTypeError] for a value of
/// another kind, including null. The `as*OrNull` getters return null instead of throwing.
extension type const JsonValue(dynamic _value) {
  /// Whether the value is a JSON null.
  bool get isNull => _value == null;

  /// The value as a [String].
  String get asString => _value is String ? _value : throw JsonTypeError<String>(_value);

  /// The value as a [String], or null when [asString] would throw.
  String? get asStringOrNull => _value is String ? _value : null;

  /// The value as a [bool].
  bool get asBool => _value is bool ? _value : throw JsonTypeError<bool>(_value);

  /// The value as a [bool], or null when [asBool] would throw.
  bool? get asBoolOrNull => _value is bool ? _value : null;

  /// The value as an [int]. A [double] with an integral value such as `1.0` converts, and a fraction throws.
  int get asInt => _integral ?? (throw JsonTypeError<int>(_value));

  /// The value as an [int], or null when [asInt] would throw.
  int? get asIntOrNull => _integral;

  /// The value as a [double]. An [int] converts to a [double].
  double get asDouble => _value is num ? _value.toDouble() : throw JsonTypeError<double>(_value);

  /// The value as a [double], or null when [asDouble] would throw.
  double? get asDoubleOrNull => _value is num ? _value.toDouble() : null;

  /// The value as a [JsonObject].
  JsonObject get asObject =>
      _value is Map<String, JsonValue> ? JsonObject(_value) : throw JsonTypeError<Map<String, JsonValue>>(_value);

  /// The value as a [JsonObject], or null when [asObject] would throw.
  JsonObject? get asObjectOrNull => _value is Map<String, JsonValue> ? JsonObject(_value) : null;

  /// The value as a [JsonArray].
  JsonArray get asArray => _value is List<JsonValue> ? JsonArray(_value) : throw JsonTypeError<List<JsonValue>>(_value);

  /// The value as a [JsonArray], or null when [asArray] would throw.
  JsonArray? get asArrayOrNull => _value is List<JsonValue> ? JsonArray(_value) : null;

  // The double branch comes first: on the web every number is a double, so its checks apply there too, while on
  // the VM an int is always finite and in range. toInt saturates beyond 2^63 instead of failing, hence the range.
  int? get _integral {
    final value = _value;
    // 2^63 is the first double above the largest int.
    const limit = 9223372036854775808.0;
    if (value is double) {
      final integral = value.isFinite && value == value.truncateToDouble() && value >= -limit && value < limit;
      return integral ? value.toInt() : null;
    }
    return value is int ? value : null;
  }
}
