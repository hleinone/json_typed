import 'json_object.dart';
import 'json_value.dart';
import 'json_errors.dart';

/// A decoded JSON array of [JsonValue] elements.
///
/// The `as*` getters convert every element and throw a [JsonTypeError] for an element of another kind. Iterable
/// members such as `first` throw a [StateError] on an empty array, as any [Iterable] does. `elementAtOrNull`
/// and `firstOrNull` return null instead.
extension type const JsonArray(List<JsonValue> _value) implements Iterable<JsonValue> {
  /// The element at [index]. Throws a [RangeError] for an index outside the array.
  JsonValue operator [](int index) => _value[index];

  /// The elements as a list of [String].
  List<String> get asStrings => _value.map((value) => value.asString).toList();

  /// The elements as a list of [bool].
  List<bool> get asBools => _value.map((value) => value.asBool).toList();

  /// The elements as a list of [int].
  List<int> get asInts => _value.map((value) => value.asInt).toList();

  /// The elements as a list of [double]. An [int] converts to a [double].
  List<double> get asDoubles => _value.map((value) => value.asDouble).toList();

  /// The elements as a list of [JsonObject].
  List<JsonObject> get asObjects => _value.map((value) => value.asObject).toList();

  /// The elements as a list of [JsonArray].
  List<JsonArray> get asArrays => _value.map((value) => value.asArray).toList();
}
