import 'package:json_typed/json_typed.dart';
import 'package:test/test.dart';

/// One sample of every JSON value kind, keyed by a name for the test descriptions.
const kinds = <String, dynamic>{
  'string': 'text',
  'bool': true,
  'int': 1,
  'double': 1.5,
  'object': <String, dynamic>{'key': 'value'},
  'array': <dynamic>[1, 2],
  'null': null,
};

Iterable<MapEntry<String, dynamic>> kindsExcept(Set<String> accepted) =>
    kinds.entries.where((entry) => !accepted.contains(entry.key));

void main() {
  group('JsonValue', () {
    group('isNull', () {
      test('returns true for null', () {
        expect(const JsonValue(null).isNull, isTrue);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'null'})) {
        test('returns false for $kind', () {
          expect(JsonValue(value).isNull, isFalse);
        });
      }
    });

    group('asString', () {
      test('returns a string', () {
        expect(const JsonValue('text').asString, 'text');
      });

      test('carries the rejected value in the error', () {
        expect(
          () => const JsonValue(1).asString,
          throwsA(isA<JsonTypeError<String>>().having((e) => e.value, 'value', 1)),
        );
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'string'})) {
        test('throws JsonTypeError<String> for $kind', () {
          expect(() => JsonValue(value).asString, throwsA(isA<JsonTypeError<String>>()));
        });
      }
    });

    group('asStringOrNull', () {
      test('returns a string', () {
        expect(const JsonValue('text').asStringOrNull, 'text');
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'string'})) {
        test('returns null for $kind', () {
          expect(JsonValue(value).asStringOrNull, isNull);
        });
      }
    });

    group('asBool', () {
      test('returns a bool', () {
        expect(const JsonValue(true).asBool, isTrue);
        expect(const JsonValue(false).asBool, isFalse);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'bool'})) {
        test('throws JsonTypeError<bool> for $kind', () {
          expect(() => JsonValue(value).asBool, throwsA(isA<JsonTypeError<bool>>()));
        });
      }
    });

    group('asBoolOrNull', () {
      test('returns a bool', () {
        expect(const JsonValue(true).asBoolOrNull, isTrue);
        expect(const JsonValue(false).asBoolOrNull, isFalse);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'bool'})) {
        test('returns null for $kind', () {
          expect(JsonValue(value).asBoolOrNull, isNull);
        });
      }
    });

    group('asInt', () {
      test('returns an int', () {
        expect(const JsonValue(1).asInt, 1);
      });

      test('converts a double with an integral value to an int', () {
        expect(const JsonValue(1.0).asInt, 1);
        expect(const JsonValue(100.0).asInt, 100);
        expect(const JsonValue(-0.0).asInt, 0);
      });

      test('throws JsonTypeError<int> for an infinite or NaN double', () {
        expect(() => const JsonValue(double.infinity).asInt, throwsA(isA<JsonTypeError<int>>()));
        expect(() => const JsonValue(double.negativeInfinity).asInt, throwsA(isA<JsonTypeError<int>>()));
        expect(() => const JsonValue(double.nan).asInt, throwsA(isA<JsonTypeError<int>>()));
      });

      test('throws JsonTypeError<int> for a double outside the int range', () {
        expect(() => const JsonValue(9223372036854775808.0).asInt, throwsA(isA<JsonTypeError<int>>()));
        expect(() => const JsonValue(-9223372036854777856.0).asInt, throwsA(isA<JsonTypeError<int>>()));
        expect(const JsonValue(-9223372036854775808.0).asInt, -9223372036854775808);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'int'})) {
        test('throws JsonTypeError<int> for $kind', () {
          expect(() => JsonValue(value).asInt, throwsA(isA<JsonTypeError<int>>()));
        });
      }
    });

    group('asIntOrNull', () {
      test('returns an int', () {
        expect(const JsonValue(1).asIntOrNull, 1);
      });

      test('converts a double with an integral value to an int', () {
        expect(const JsonValue(1.0).asIntOrNull, 1);
      });

      test('returns null for an infinite double', () {
        expect(const JsonValue(double.infinity).asIntOrNull, isNull);
      });

      test('returns null for a double outside the int range', () {
        expect(const JsonValue(9223372036854775808.0).asIntOrNull, isNull);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'int'})) {
        test('returns null for $kind', () {
          expect(JsonValue(value).asIntOrNull, isNull);
        });
      }
    });

    group('asDouble', () {
      test('returns a double', () {
        expect(const JsonValue(1.5).asDouble, 1.5);
      });

      test('converts an int to a double', () {
        expect(const JsonValue(1).asDouble, isA<double>());
        expect(const JsonValue(1).asDouble, 1.0);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'int', 'double'})) {
        test('throws JsonTypeError<double> for $kind', () {
          expect(() => JsonValue(value).asDouble, throwsA(isA<JsonTypeError<double>>()));
        });
      }
    });

    group('asDoubleOrNull', () {
      test('returns a double', () {
        expect(const JsonValue(1.5).asDoubleOrNull, 1.5);
      });

      test('converts an int to a double', () {
        expect(const JsonValue(1).asDoubleOrNull, isA<double>());
        expect(const JsonValue(1).asDoubleOrNull, 1.0);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'int', 'double'})) {
        test('returns null for $kind', () {
          expect(JsonValue(value).asDoubleOrNull, isNull);
        });
      }
    });

    group('asObject', () {
      test('wraps a map', () {
        final object = JsonValue(<String, dynamic>{'key': 'value'}).asObject;
        expect(object, {'key': 'value'});
        expect(object.getString('key'), 'value');
      });

      test('accepts a map with typed values', () {
        expect(JsonValue(<String, int>{'key': 1}).asObject, {'key': 1});
      });

      test('throws JsonTypeError for a map with dynamic keys', () {
        expect(
          () => JsonValue(<dynamic, dynamic>{'key': 'value'}).asObject,
          throwsA(isA<JsonTypeError<Map<String, JsonValue>>>()),
        );
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'object'})) {
        test('throws JsonTypeError for $kind', () {
          expect(() => JsonValue(value).asObject, throwsA(isA<JsonTypeError<Map<String, JsonValue>>>()));
        });
      }
    });

    group('asObjectOrNull', () {
      test('wraps a map', () {
        expect(JsonValue(<String, dynamic>{'key': 'value'}).asObjectOrNull, {'key': 'value'});
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'object'})) {
        test('returns null for $kind', () {
          expect(JsonValue(value).asObjectOrNull, isNull);
        });
      }
    });

    group('asArray', () {
      test('wraps a list', () {
        final array = JsonValue(<dynamic>[1, 'two', null]).asArray;
        expect(array, [1, 'two', null]);
        expect(array.first.asInt, 1);
      });

      test('accepts a list with typed elements', () {
        expect(JsonValue(<int>[1, 2]).asArray, [1, 2]);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'array'})) {
        test('throws JsonTypeError for $kind', () {
          expect(() => JsonValue(value).asArray, throwsA(isA<JsonTypeError<List<JsonValue>>>()));
        });
      }
    });

    group('asArrayOrNull', () {
      test('wraps a list', () {
        expect(JsonValue(<dynamic>[1, 2]).asArrayOrNull, [1, 2]);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'array'})) {
        test('returns null for $kind', () {
          expect(JsonValue(value).asArrayOrNull, isNull);
        });
      }
    });
  });
}
