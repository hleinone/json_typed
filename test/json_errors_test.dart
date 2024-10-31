import 'package:json_typed/json_typed.dart';
import 'package:test/test.dart';

void main() {
  group('JsonKeyNotFoundError', () {
    test('is a JsonKeyError that exposes the key', () {
      final error = JsonKeyNotFoundError('id');
      expect(error, isA<JsonKeyError>());
      expect(error, isA<Error>());
      expect(error.key, 'id');
    });

    test('names the key in toString', () {
      expect(JsonKeyNotFoundError('id').toString(), 'JsonKeyNotFoundError: Value for key "id" is not found');
    });
  });

  group('JsonKeyTypeError', () {
    test('is a JsonKeyError and a JsonTypeError that exposes the key and the value', () {
      final error = JsonKeyTypeError<int>('id', 'text');
      expect(error, isA<JsonKeyError>());
      expect(error, isA<JsonTypeError<int>>());
      expect(error, isA<Error>());
      expect(error.key, 'id');
      expect(error.value, 'text');
    });

    test('names the value, the key and the expected type in toString', () {
      expect(
        JsonKeyTypeError<int>('id', 'text').toString(),
        'JsonKeyTypeError: Value "text" for key "id" is not of type int',
      );
    });
  });

  group('JsonTypeError', () {
    test('is an Error that exposes the value', () {
      final error = JsonTypeError<int>('text');
      expect(error, isA<Error>());
      expect(error.value, 'text');
    });

    test('names the value and the expected type in toString', () {
      expect(JsonTypeError<int>('text').toString(), 'JsonTypeError: Value "text" is not of type int');
    });
  });
}
