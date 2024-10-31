import 'package:json_typed/json_typed.dart';
import 'package:test/test.dart';

void main() {
  group('jsonDecodeObject', () {
    test('decodes a JSON object', () {
      final object = jsonDecodeObject('{"name": "Ann", "age": 30, "active": true}');
      expect(object.getString('name'), 'Ann');
      expect(object.getInt('age'), 30);
      expect(object.getBool('active'), isTrue);
    });

    test('decodes nested objects and arrays', () {
      final object = jsonDecodeObject('{"user": {"score": 1.5, "tags": ["a", "b"]}}');
      final user = object.getObject('user');
      expect(user.getDouble('score'), 1.5);
      expect(user.getArray('tags'), ['a', 'b']);
    });

    test('decodes an empty object', () {
      expect(jsonDecodeObject('{}'), isEmpty);
    });

    test('treats a JSON null like a missing key', () {
      final object = jsonDecodeObject('{"name": null}');
      expect(object.getStringOrNull('name'), isNull);
      expect(() => object.getString('name'), throwsA(isA<JsonKeyNotFoundError>()));
    });

    test('throws JsonTypeError for a JSON array', () {
      expect(
        () => jsonDecodeObject('[1, 2]'),
        throwsA(isA<JsonTypeError<Map<String, JsonValue>>>().having((e) => e.value, 'value', [1, 2])),
      );
    });

    test('throws JsonTypeError for a top-level null', () {
      expect(() => jsonDecodeObject('null'), throwsA(isA<JsonTypeError<Map<String, JsonValue>>>()));
    });

    test('throws FormatException for malformed JSON', () {
      expect(() => jsonDecodeObject('{"name": '), throwsFormatException);
    });
  });

  group('jsonDecodeArray', () {
    test('decodes a JSON array', () {
      expect(jsonDecodeArray('[1, "two", true, null]'), [1, 'two', true, null]);
    });

    test('decodes nested objects', () {
      final array = jsonDecodeArray('[{"id": 1}, {"id": 2}]');
      expect(array.asObjects.map((object) => object.getInt('id')), [1, 2]);
    });

    test('decodes an empty array', () {
      expect(jsonDecodeArray('[]'), isEmpty);
    });

    test('throws JsonTypeError for a JSON object', () {
      expect(
        () => jsonDecodeArray('{"id": 1}'),
        throwsA(isA<JsonTypeError<List<JsonValue>>>().having((e) => e.value, 'value', {'id': 1})),
      );
    });

    test('throws JsonTypeError for a top-level number', () {
      expect(() => jsonDecodeArray('42'), throwsA(isA<JsonTypeError<List<JsonValue>>>()));
    });

    test('throws FormatException for malformed JSON', () {
      expect(() => jsonDecodeArray('[1, '), throwsFormatException);
    });
  });

  group('jsonDecodeValue', () {
    test('decodes a top-level string', () {
      expect(jsonDecodeValue('"text"').asString, 'text');
    });

    test('decodes a top-level number', () {
      expect(jsonDecodeValue('42').asInt, 42);
      expect(jsonDecodeValue('1.5').asDouble, 1.5);
    });

    test('decodes a top-level bool', () {
      expect(jsonDecodeValue('true').asBool, isTrue);
      expect(jsonDecodeValue('false').asBool, isFalse);
    });

    test('decodes a top-level null', () {
      expect(jsonDecodeValue('null'), isNull);
      expect(jsonDecodeValue('null').asStringOrNull, isNull);
    });

    test('decodes an object', () {
      expect(jsonDecodeValue('{"id": 1}').asObject.getInt('id'), 1);
    });

    test('decodes an array', () {
      expect(jsonDecodeValue('[1, 2]').asArray.asInts, [1, 2]);
    });

    test('accepts surrounding whitespace', () {
      expect(jsonDecodeValue(' 42 ').asInt, 42);
    });

    test('throws FormatException for malformed JSON', () {
      expect(() => jsonDecodeValue('"text'), throwsFormatException);
    });

    test('throws FormatException for an empty document', () {
      expect(() => jsonDecodeValue(''), throwsFormatException);
    });
  });
}
