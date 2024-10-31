import 'package:json_typed/json_typed.dart';

void main() {
  final user = jsonDecodeObject('''
    {
      "name": "Ann",
      "age": 30,
      "score": 4,
      "active": true,
      "nickname": null,
      "address": {"city": "Helsinki"},
      "tags": ["admin", "beta"]
    }
  ''');

  // Typed getters return the value or throw.
  final name = user.getString('name');
  final age = user.getInt('age');
  final active = user.getBool('active');

  // Double getters accept an int and convert it.
  final score = user.getDouble('score');

  // OrNull getters return null for a missing key, a JSON null or a value of another type.
  final nickname = user.getStringOrNull('nickname');

  // The fallback applies to a missing key and to a JSON null.
  final role = user.getString('role', or: 'member');

  final city = user.getObject('address').getString('city');

  // A JsonArray is an Iterable<JsonValue>. The typed getters convert the whole array.
  final tags = user.getArray('tags');
  for (final tag in tags) {
    print('tag: ${tag.asString}');
  }
  final tagNames = tags.asStrings;

  print('$name, $age, active: $active, score: $score');
  print('nickname: $nickname, role: $role, city: $city, tags: $tagNames');

  try {
    user.getInt('name');
  } on JsonKeyTypeError catch (error) {
    print(error); // JsonKeyTypeError: Value "Ann" for key "name" is not of type int
  }

  try {
    user.getString('email');
  } on JsonKeyNotFoundError catch (error) {
    print(error); // JsonKeyNotFoundError: Value for key "email" is not found
  }
}
