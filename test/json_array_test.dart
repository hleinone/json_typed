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

/// Wraps a raw list the same way the decode boundary does.
JsonArray arrayOf(List<dynamic> values) => JsonValue(values).asArray;

void main() {
  group('JsonArray', () {
    group('as an Iterable', () {
      test('reports length', () {
        expect(arrayOf([1, 2, 3]).length, 3);
        expect(arrayOf([]).length, 0);
      });

      test('reports isEmpty and isNotEmpty', () {
        expect(arrayOf([]).isEmpty, isTrue);
        expect(arrayOf([1]).isNotEmpty, isTrue);
      });

      test('iterates the elements in order', () {
        final seen = <int>[];
        for (final value in arrayOf([1, 2, 3])) {
          seen.add(value.asInt);
        }
        expect(seen, [1, 2, 3]);
      });

      test('exposes first and last', () {
        final array = arrayOf(['a', 'b']);
        expect(array.first.asString, 'a');
        expect(array.last.asString, 'b');
      });

      test('returns null from elementAtOrNull past the end', () {
        expect(arrayOf([1]).elementAtOrNull(1), isNull);
      });

      test('throws StateError from first on an empty array', () {
        expect(() => arrayOf([]).first, throwsStateError);
      });

      test('returns null from firstOrNull on an empty array', () {
        expect(arrayOf([]).firstOrNull, isNull);
      });

      test('maps the elements', () {
        expect(arrayOf([1, 2]).map((value) => value.asInt * 10), [10, 20]);
      });

      test('filters the elements', () {
        final strings = arrayOf([1, 'a', 2, 'b']).where((value) => value.asStringOrNull != null);
        expect(strings.map((value) => value.asString), ['a', 'b']);
      });
    });

    group('[]', () {
      test('returns the element at an index', () {
        expect(arrayOf(['a', 'b'])[1].asString, 'b');
      });

      test('throws RangeError past the end', () {
        expect(() => arrayOf(['a'])[1], throwsRangeError);
      });

      test('throws RangeError for a negative index', () {
        expect(() => arrayOf(['a'])[-1], throwsRangeError);
      });

      test('wraps a null element', () {
        final value = arrayOf([null])[0];
        expect(value.asStringOrNull, isNull);
        expect(() => value.asString, throwsA(isA<JsonTypeError<String>>()));
      });

      test('tells a null element from a value with isNull', () {
        final array = arrayOf([null, 1]);
        expect(array[0].isNull, isTrue);
        expect(array[1].isNull, isFalse);
      });
    });

    group('asStrings', () {
      test('converts every element', () {
        final strings = arrayOf(['a', 'b']).asStrings;
        expect(strings, isA<List<String>>());
        expect(strings, ['a', 'b']);
      });

      test('returns an empty list for an empty array', () {
        expect(arrayOf([]).asStrings, isEmpty);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'string'})) {
        test('throws JsonTypeError<String> for a $kind element', () {
          expect(() => arrayOf(['a', value]).asStrings, throwsA(isA<JsonTypeError<String>>()));
        });
      }
    });

    group('asBools', () {
      test('converts every element', () {
        final bools = arrayOf([true, false]).asBools;
        expect(bools, isA<List<bool>>());
        expect(bools, [true, false]);
      });

      test('returns an empty list for an empty array', () {
        expect(arrayOf([]).asBools, isEmpty);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'bool'})) {
        test('throws JsonTypeError<bool> for a $kind element', () {
          expect(() => arrayOf([true, value]).asBools, throwsA(isA<JsonTypeError<bool>>()));
        });
      }
    });

    group('asInts', () {
      test('converts every element', () {
        final ints = arrayOf([1, 2]).asInts;
        expect(ints, isA<List<int>>());
        expect(ints, [1, 2]);
      });

      test('converts double elements with integral values to ints', () {
        expect(arrayOf([1, 2.0]).asInts, [1, 2]);
      });

      test('returns an empty list for an empty array', () {
        expect(arrayOf([]).asInts, isEmpty);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'int'})) {
        test('throws JsonTypeError<int> for a $kind element', () {
          expect(() => arrayOf([1, value]).asInts, throwsA(isA<JsonTypeError<int>>()));
        });
      }
    });

    group('asDoubles', () {
      test('converts every element', () {
        final doubles = arrayOf([1.5, 2.5]).asDoubles;
        expect(doubles, isA<List<double>>());
        expect(doubles, [1.5, 2.5]);
      });

      test('converts int elements to doubles', () {
        final doubles = arrayOf([1, 2.5]).asDoubles;
        expect(doubles, isA<List<double>>());
        expect(doubles, [1.0, 2.5]);
      });

      test('returns an empty list for an empty array', () {
        expect(arrayOf([]).asDoubles, isEmpty);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'int', 'double'})) {
        test('throws JsonTypeError<double> for a $kind element', () {
          expect(() => arrayOf([1.5, value]).asDoubles, throwsA(isA<JsonTypeError<double>>()));
        });
      }
    });

    group('asObjects', () {
      test('converts every element', () {
        final objects = arrayOf([
          {'id': 1},
          {'id': 2},
        ]).asObjects;
        expect(objects.map((object) => object.getInt('id')), [1, 2]);
      });

      test('returns an empty list for an empty array', () {
        expect(arrayOf([]).asObjects, isEmpty);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'object'})) {
        test('throws JsonTypeError for a $kind element', () {
          expect(
            () => arrayOf([<String, dynamic>{}, value]).asObjects,
            throwsA(isA<JsonTypeError<Map<String, JsonValue>>>()),
          );
        });
      }
    });

    group('asArrays', () {
      test('converts every element', () {
        final arrays = arrayOf([
          [1],
          [2, 3],
        ]).asArrays;
        expect(arrays.map((array) => array.length), [1, 2]);
        expect(arrays[1][1].asInt, 3);
      });

      test('returns an empty list for an empty array', () {
        expect(arrayOf([]).asArrays, isEmpty);
      });

      for (final MapEntry(key: kind, :value) in kindsExcept({'array'})) {
        test('throws JsonTypeError for a $kind element', () {
          expect(() => arrayOf([<dynamic>[], value]).asArrays, throwsA(isA<JsonTypeError<List<JsonValue>>>()));
        });
      }
    });

    group('construction', () {
      test('wraps JsonValue elements', () {
        expect(const JsonArray([JsonValue(1), JsonValue(2)]), [1, 2]);
      });

      test('equals its underlying list', () {
        expect(arrayOf([1, 'two', null]), [1, 'two', null]);
      });
    });
  });
}
