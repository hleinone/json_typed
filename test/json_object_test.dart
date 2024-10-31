import 'package:json_typed/json_typed.dart';
import 'package:test/test.dart';

/// Holds one value of every JSON kind under a key named after the kind.
final sample = jsonDecodeObject('''
{
  "string": "text",
  "bool": true,
  "int": 1,
  "double": 1.5,
  "object": {"key": "value"},
  "array": [1, 2],
  "null": null
}
''');

void main() {
  group('JsonObject', () {
    group('[]', () {
      test('returns the value for a present key', () {
        expect(sample['string']?.asString, 'text');
      });

      test('returns null for a missing key', () {
        expect(sample['missing'], isNull);
      });

      test('returns null for a null value', () {
        expect(sample['null'], isNull);
      });
    });

    group('containsKey', () {
      test('returns true for a present key', () {
        expect(sample.containsKey('string'), isTrue);
      });

      test('returns true for a key that holds a null value', () {
        expect(sample.containsKey('null'), isTrue);
      });

      test('returns false for a missing key', () {
        expect(sample.containsKey('missing'), isFalse);
      });
    });

    group('getValue', () {
      test('returns the value', () {
        expect(sample.getValue('string'), const JsonValue('text'));
      });

      test('returns a null JsonValue for a null value', () {
        expect(sample.getValue('null').isNull, isTrue);
      });

      test('throws JsonKeyNotFoundError for a missing key', () {
        expect(
          () => sample.getValue('missing'),
          throwsA(isA<JsonKeyNotFoundError>().having((e) => e.key, 'key', 'missing')),
        );
      });
    });

    group('getValueOrNull', () {
      test('returns the value', () {
        expect(sample.getValueOrNull('string'), const JsonValue('text'));
      });

      test('returns null for a missing key', () {
        expect(sample.getValueOrNull('missing'), isNull);
      });

      test('returns null for a null value', () {
        expect(sample.getValueOrNull('null'), isNull);
      });
    });

    testTypedGetters<String>(
      name: 'getString',
      key: 'string',
      otherKey: 'int',
      expected: 'text',
      fallback: 'fallback',
      get: sample.getString,
      getOrNull: sample.getStringOrNull,
    );

    testTypedGetters<bool>(
      name: 'getBool',
      key: 'bool',
      otherKey: 'string',
      expected: true,
      fallback: false,
      get: sample.getBool,
      getOrNull: sample.getBoolOrNull,
    );

    testTypedGetters<int>(
      name: 'getInt',
      key: 'int',
      otherKey: 'string',
      expected: 1,
      fallback: -1,
      get: sample.getInt,
      getOrNull: sample.getIntOrNull,
    );

    group('getInt', () {
      test('converts a double with an integral value to an int', () {
        expect(jsonDecodeObject('{"count": 2.0}').getInt('count'), 2);
      });

      test('throws JsonKeyTypeError for a double with a fraction', () {
        expect(
          () => sample.getInt('double'),
          throwsA(isA<JsonKeyTypeError<int>>().having((e) => e.key, 'key', 'double')),
        );
      });
    });

    group('getIntOrNull', () {
      test('returns null for a double', () {
        expect(sample.getIntOrNull('double'), isNull);
      });
    });

    testTypedGetters<double>(
      name: 'getDouble',
      key: 'double',
      otherKey: 'string',
      expected: 1.5,
      fallback: -1.0,
      get: sample.getDouble,
      getOrNull: sample.getDoubleOrNull,
    );

    group('getDouble', () {
      test('converts an int to a double', () {
        expect(sample.getDouble('int'), isA<double>());
        expect(sample.getDouble('int'), 1.0);
      });
    });

    group('getDoubleOrNull', () {
      test('converts an int to a double', () {
        expect(sample.getDoubleOrNull('int'), isA<double>());
        expect(sample.getDoubleOrNull('int'), 1.0);
      });
    });

    testTypedGetters<JsonObject>(
      name: 'getObject',
      key: 'object',
      otherKey: 'string',
      expected: const JsonObject({'key': JsonValue('value')}),
      fallback: const JsonObject({'fallback': JsonValue(true)}),
      get: sample.getObject,
      getOrNull: sample.getObjectOrNull,
    );

    group('getObject', () {
      test('returns an object that supports chained access', () {
        expect(sample.getObject('object').getString('key'), 'value');
      });
    });

    testTypedGetters<JsonArray>(
      name: 'getArray',
      key: 'array',
      otherKey: 'string',
      expected: const JsonArray([JsonValue(1), JsonValue(2)]),
      fallback: const JsonArray([]),
      get: sample.getArray,
      getOrNull: sample.getArrayOrNull,
    );

    group('entries', () {
      test('yields every entry in order', () {
        final keys = sample.entries.map((entry) => entry.key);
        final values = sample.entries.map((entry) => entry.value);
        expect(keys, ['string', 'bool', 'int', 'double', 'object', 'array', 'null']);
        expect(values, [
          'text',
          true,
          1,
          1.5,
          {'key': 'value'},
          [1, 2],
          null
        ]);
      });

      test('yields values that support typed access', () {
        final value = sample.entries.firstWhere((entry) => entry.key == 'int').value;
        expect(value.asInt, 1);
      });

      test('yields a JSON null as a value whose isNull is true', () {
        final value = sample.entries.firstWhere((entry) => entry.key == 'null').value;
        expect(value.isNull, isTrue);
      });

      test('is empty for an empty object', () {
        expect(jsonDecodeObject('{}').entries, isEmpty);
      });
    });

    group('construction', () {
      test('wraps JsonValue entries', () {
        expect(const JsonObject({'key': JsonValue('value')}), {'key': 'value'});
      });

      test('equals its underlying map', () {
        expect(sample, {
          'string': 'text',
          'bool': true,
          'int': 1,
          'double': 1.5,
          'object': {'key': 'value'},
          'array': [1, 2],
          'null': null,
        });
      });
    });
  });
}

/// Registers the tests that every typed getter pair shares.
///
/// [key] names the entry of [sample] that holds a value of type [T].
/// [otherKey] names an entry that holds a value of another type.
void testTypedGetters<T>({
  required String name,
  required String key,
  required String otherKey,
  required T expected,
  required T fallback,
  required T Function(String key, {T? or}) get,
  required T? Function(String key) getOrNull,
}) {
  final isKeyTypeError = isA<JsonKeyTypeError<T>>()
      .having((e) => e.key, 'key', otherKey)
      .having((e) => e.value, 'value', sample[otherKey]);

  group(name, () {
    test('returns the value', () {
      expect(get(key), expected);
    });

    test('returns the value when a fallback is given', () {
      expect(get(key, or: fallback), expected);
    });

    test('returns the fallback for a missing key', () {
      expect(get('missing', or: fallback), fallback);
    });

    test('returns the fallback for a null value', () {
      expect(get('null', or: fallback), fallback);
    });

    test('throws JsonKeyNotFoundError for a missing key', () {
      expect(
        () => get('missing'),
        throwsA(isA<JsonKeyNotFoundError>().having((e) => e.key, 'key', 'missing')),
      );
    });

    test('throws JsonKeyNotFoundError for a null value', () {
      expect(
        () => get('null'),
        throwsA(isA<JsonKeyNotFoundError>().having((e) => e.key, 'key', 'null')),
      );
    });

    test('throws JsonKeyTypeError for a value of another type', () {
      expect(() => get(otherKey), throwsA(isKeyTypeError));
    });

    test('throws JsonKeyTypeError for a value of another type when a fallback is given', () {
      expect(() => get(otherKey, or: fallback), throwsA(isKeyTypeError));
    });
  });

  group('${name}OrNull', () {
    test('returns the value', () {
      expect(getOrNull(key), expected);
    });

    test('returns null for a missing key', () {
      expect(getOrNull('missing'), isNull);
    });

    test('returns null for a null value', () {
      expect(getOrNull('null'), isNull);
    });

    test('returns null for a value of another type', () {
      expect(getOrNull(otherKey), isNull);
    });
  });
}
