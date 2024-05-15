// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:jayse/jayse.dart';
import 'package:test/test.dart';

void main() {
  group('Basic Examples', () {
    test('Basic JSON to object', () {
      const bookJson =
          '{"title": "The Great Gatsby", "author": "F. Scott Fitzgerald"}';

      final book = jsonValueDecode(bookJson) as JsonObject;
      final titleValue = book['title'] as JsonString;
      expect(titleValue.value, 'The Great Gatsby');
      expect(book['title'], const JsonString('The Great Gatsby'));
      expect(book['author'], const JsonString('F. Scott Fitzgerald'));
    });

    test('Nested Object Test', () {
      final person = JsonValue.fromJson(<String, dynamic>{
        'name': 'John Doe',
        'age': 30,
        'isEmployed': true,
        'address': {
          'street': '123 Main St',
          'city': 'New York',
          'country': 'USA',
        },
      });

      expect(
        person['address']['street'].stringValue,
        '123 Main St',
      );
      expect(
        person['age'].numericValue,
        30,
      );
    });

    test('Missing Value Test', () {
      const bookJson = '{"title": "The Great Gatsby"}';

      final book = jsonValueDecode(bookJson) as JsonObject;
      final nameValue = book['author']['name'];
      expect(nameValue, const Undefined());
    });
  });

  group('Serialization and Deserialization Tests', () {
    test('encode and decode with primitive values', () {
      const stringFieldName = 'message';
      const stringFieldValue = 'hello';

      const numberFieldName = 'count';
      const numberFieldValue = 42;

      const boolFieldName = 'isActive';
      const boolFieldValue = true;

      const jsonText =
          '{"$stringFieldName":"$stringFieldValue","$numberFieldName":'
          '$numberFieldValue,"$boolFieldName":$boolFieldValue}';

      final jsonValue = jsonValueDecode(jsonText) as JsonObject;

      // Check string field
      expect(jsonValue[stringFieldName], isA<JsonString>());
      expect(
        (jsonValue[stringFieldName] as JsonString).value,
        equals(stringFieldValue),
      );

      // Check number field
      expect(jsonValue[numberFieldName], isA<JsonNumber>());
      expect(
        (jsonValue[numberFieldName] as JsonNumber).value,
        equals(numberFieldValue),
      );

      // Check boolean field
      expect(jsonValue[boolFieldName], isA<JsonBoolean>());
      expect(
        (jsonValue[boolFieldName] as JsonBoolean).value,
        equals(boolFieldValue),
      );

      // Check that JSON is preserved
      expect(
        jsonValueEncode(jsonValue),
        equals(jsonText),
      );
    });

    test('encode and decode with arrays of primitive values', () {
      const stringArrayFieldName = 'tags';
      const stringArrayFieldValue = ['flutter', 'dart', 'json'];

      const numberArrayFieldName = 'numbers';
      const numberArrayFieldValue = [1, 2, 3, 4, 5];

      const boolArrayFieldName = 'flags';
      const boolArrayFieldValue = [true, false, true];

      final jsonText =
          '{"$stringArrayFieldName":${jsonEncode(stringArrayFieldValue)},'
          '"$numberArrayFieldName":${jsonEncode(numberArrayFieldValue)},'
          '"$boolArrayFieldName":${jsonEncode(boolArrayFieldValue)}}';

      final jsonObject = jsonValueDecode(jsonText) as JsonObject;

      // Check string array field
      expect(jsonObject[stringArrayFieldName], isA<JsonArray>());
      final stringArray = jsonObject[stringArrayFieldName] as JsonArray;
      expect(stringArray.value, hasLength(stringArrayFieldValue.length));
      for (var i = 0; i < stringArrayFieldValue.length; i++) {
        expect(stringArray.value[i], isA<JsonString>());
        expect(
          (stringArray.value[i] as JsonString).value,
          equals(stringArrayFieldValue[i]),
        );
      }

      // Check number array field
      expect(jsonObject[numberArrayFieldName], isA<JsonArray>());
      final numberArray = jsonObject[numberArrayFieldName] as JsonArray;
      expect(numberArray.value, hasLength(numberArrayFieldValue.length));
      for (var i = 0; i < numberArrayFieldValue.length; i++) {
        expect(numberArray.value[i], isA<JsonNumber>());
        expect(
          (numberArray.value[i] as JsonNumber).value,
          equals(numberArrayFieldValue[i]),
        );
      }

      // Check boolean array field
      expect(jsonObject[boolArrayFieldName], isA<JsonArray>());
      final boolArray = jsonObject[boolArrayFieldName] as JsonArray;
      expect(boolArray.value, hasLength(boolArrayFieldValue.length));
      for (var i = 0; i < boolArrayFieldValue.length; i++) {
        expect(boolArray.value[i], isA<JsonBoolean>());
        expect(
          (boolArray.value[i] as JsonBoolean).value,
          equals(boolArrayFieldValue[i]),
        );
      }

      // Check that JSON is preserved
      expect(jsonValueEncode(jsonObject), equals(jsonText));
    });

    test('encode and decode with complex objects', () {
      const personFieldName = 'person';
      const personFieldValue = <String, dynamic>{
        'name': 'John Doe',
        'age': 30,
        'isEmployed': true,
        'address': {
          'street': '123 Main St',
          'city': 'New York',
          'country': 'USA',
        },
      };

      const companyFieldName = 'company';
      const companyFieldValue = {
        'name': 'Acme Inc.',
        'founded': 1950,
        'isPublic': false,
        'founders': [
          {'name': 'John Smith', 'age': 70},
          {'name': 'Jane Doe', 'age': 65},
        ],
      };

      final jsonText = '{"$personFieldName":${jsonEncode(personFieldValue)},'
          '"$companyFieldName":${jsonEncode(companyFieldValue)}}';

      final jsonValue = jsonValueDecode(jsonText) as JsonObject;

      // Check person field
      expect(jsonValue[personFieldName], isA<JsonObject>());
      final person = jsonValue[personFieldName] as JsonObject;
      expect(person['name'], isA<JsonString>());
      expect(
        (person['name'] as JsonString).value,
        equals(personFieldValue['name']),
      );
      expect(person['age'], isA<JsonNumber>());
      expect(
        (person['age'] as JsonNumber).value,
        equals(personFieldValue['age']),
      );
      expect(person['isEmployed'], isA<JsonBoolean>());
      expect(
        (person['isEmployed'] as JsonBoolean).value,
        equals(personFieldValue['isEmployed']),
      );

      expect(person['address'], isA<JsonObject>());
      final address = person['address'] as JsonObject;
      expect(address['street'], isA<JsonString>());
      expect(
        (address['street'] as JsonString).value,
        equals(personFieldValue['address']['street']),
      );
      expect(address['city'], isA<JsonString>());
      expect(
        (address['city'] as JsonString).value,
        equals(personFieldValue['address']['city']),
      );
      expect(address['country'], isA<JsonString>());
      expect(
        (address['country'] as JsonString).value,
        equals(personFieldValue['address']['country']),
      );

      // Check company field
      expect(jsonValue[companyFieldName], isA<JsonObject>());
      final company = jsonValue[companyFieldName] as JsonObject;
      expect(company['name'], isA<JsonString>());
      expect(
        (company['name'] as JsonString).value,
        equals(companyFieldValue['name']),
      );
      expect(company['founded'], isA<JsonNumber>());
      expect(
        (company['founded'] as JsonNumber).value,
        equals(companyFieldValue['founded']),
      );
      expect(company['isPublic'], isA<JsonBoolean>());
      expect(
        (company['isPublic'] as JsonBoolean).value,
        equals(companyFieldValue['isPublic']),
      );

      // Check that JSON is preserved
      expect(jsonValueEncode(jsonValue), equals(jsonText));
    });

    test('encode and decode with all types combined', () {
      const userFieldName = 'user';
      const userFieldValue = <String, dynamic>{
        'id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'age': 30,
        'isActive': true,
        'roles': ['admin', 'user'],
        'scores': [85.5, 92.0, 78.3],
        'preferences': [true, false, true],
        'address': {
          'street': '123 Main St',
          'city': 'New York',
          'country': 'USA',
        },
        'education': [
          {
            'degree': 'Bachelor',
            'major': 'Computer Science',
            'year': 2015,
          },
          {
            'degree': 'Master',
            'major': 'Software Engineering',
            'year': 2018,
          },
        ],
      };

      final jsonText = '{"$userFieldName":${jsonEncode(userFieldValue)}}';

      final jsonValue = jsonValueDecode(jsonText) as JsonObject;

      // Check user field
      expect(jsonValue[userFieldName], isA<JsonObject>());
      final user = jsonValue[userFieldName] as JsonObject;

      // Check primitive fields
      expect(user['id'], isA<JsonString>());
      expect(
        (user['id'] as JsonString).value,
        equals(userFieldValue['id']),
      );
      expect(user['name'], isA<JsonString>());
      expect(
        (user['name'] as JsonString).value,
        equals(userFieldValue['name']),
      );
      expect(user['email'], isA<JsonString>());
      expect(
        (user['email'] as JsonString).value,
        equals(userFieldValue['email']),
      );
      expect(user['age'], isA<JsonNumber>());
      expect(
        (user['age'] as JsonNumber).value,
        equals(userFieldValue['age']),
      );
      expect(user['isActive'], isA<JsonBoolean>());
      expect(
        (user['isActive'] as JsonBoolean).value,
        equals(userFieldValue['isActive']),
      );

      // Check array fields
      expect(user['roles'], isA<JsonArray>());
      final roles = user['roles'] as JsonArray;
      expect(roles.value, hasLength(userFieldValue['roles'].length));
      for (var i = 0; i < (userFieldValue['roles'] as List).length; i++) {
        expect(roles.value[i], isA<JsonString>());
        expect(
          (roles.value[i] as JsonString).value,
          equals(userFieldValue['roles'][i]),
        );
      }

      expect(user['scores'], isA<JsonArray>());
      final scores = user['scores'] as JsonArray;
      expect(scores.value, hasLength(userFieldValue['scores'].length));
      for (var i = 0; i < (userFieldValue['scores'] as List).length; i++) {
        expect(scores.value[i], isA<JsonNumber>());
        expect(
          (scores.value[i] as JsonNumber).value,
          equals(userFieldValue['scores'][i]),
        );
      }

      expect(user['preferences'], isA<JsonArray>());
      final preferences = user['preferences'] as JsonArray;
      expect(
        preferences.value,
        hasLength(userFieldValue['preferences'].length),
      );
      for (var i = 0; i < (userFieldValue['preferences'] as List).length; i++) {
        expect(preferences.value[i], isA<JsonBoolean>());
        expect(
          (preferences.value[i] as JsonBoolean).value,
          equals(userFieldValue['preferences'][i]),
        );
      }

      // Check nested object field
      expect(user['address'], isA<JsonObject>());
      final address = user['address'] as JsonObject;
      expect(address['street'], isA<JsonString>());
      expect(
        (address['street'] as JsonString).value,
        equals(userFieldValue['address']['street']),
      );
      expect(address['city'], isA<JsonString>());
      expect(
        (address['city'] as JsonString).value,
        equals(userFieldValue['address']['city']),
      );
      expect(address['country'], isA<JsonString>());
      expect(
        (address['country'] as JsonString).value,
        equals(userFieldValue['address']['country']),
      );

      // Check array of objects field
      expect(user['education'], isA<JsonArray>());
      final education = user['education'] as JsonArray;
      expect(education.value, hasLength(userFieldValue['education'].length));
      for (var i = 0; i < (userFieldValue['education'] as List).length; i++) {
        final educationObj = education.value[i] as JsonObject;
        expect(educationObj['degree'], isA<JsonString>());
        expect(
          (educationObj['degree'] as JsonString).value,
          equals(userFieldValue['education'][i]['degree']),
        );
        expect(educationObj['major'], isA<JsonString>());
        expect(
          (educationObj['major'] as JsonString).value,
          equals(userFieldValue['education'][i]['major']),
        );
        expect(educationObj['year'], isA<JsonNumber>());
        expect(
          (educationObj['year'] as JsonNumber).value,
          equals(userFieldValue['education'][i]['year']),
        );
      }

      // Check that JSON is preserved
      expect(jsonValueEncode(jsonValue), equals(jsonText));
    });

    test('Equality test for all JSON value types', () {
      // Test string equality
      const stringJson = '{"message": "Hello, world!"}';
      final stringObj = jsonValueDecode(stringJson) as JsonObject;
      expect(stringObj['message'], const JsonString('Hello, world!'));

      // Test number equality
      const numberJson = '{"value": 42}';
      final numberObj = jsonValueDecode(numberJson) as JsonObject;
      expect(numberObj['value'], const JsonNumber(42));

      // Test boolean equality
      const booleanJson = '{"isActive": true}';
      final booleanObj = jsonValueDecode(booleanJson) as JsonObject;
      expect(booleanObj['isActive'], const JsonBoolean(true));

      // Test null equality
      const nullJson = '{"data": null}';
      final nullObj = jsonValueDecode(nullJson) as JsonObject;
      expect(nullObj['data'], const JsonNull());

      // Test array equality
      const arrayJson = '{"numbers": [1, 2, 3]}';
      final arrayObj = jsonValueDecode(arrayJson) as JsonObject;
      expect(
        arrayObj['numbers'],
        const JsonArray(
          [JsonNumber(1), JsonNumber(2), JsonNumber(3)],
        ),
      );

      // Test object equality
      const objectJson = '{"person": {"name": "John", "age": 30}}';
      final objectObj = jsonValueDecode(objectJson) as JsonObject;
      expect(
        objectObj['person'],
        const JsonObject({
          'name': JsonString('John'),
          'age': JsonNumber(30),
        }),
      );

      // Test complex object equality
      const complexJson = '''
    {
      "id": 123,
      "name": "John Doe",
      "email": "john@example.com",
      "isActive": true,
      "scores": [85, 92, 78],
      "address": {
        "street": "123 Main St",
        "city": "New York",
        "country": "USA"
      },
      "tags": ["developer", "engineer"],
      "preferences": [true, false, true],
      "status": null
    }
  ''';
      final complexObj = jsonValueDecode(complexJson) as JsonObject;
      expect(
        complexObj,
        const JsonObject({
          'id': JsonNumber(123),
          'name': JsonString('John Doe'),
          'email': JsonString('john@example.com'),
          'isActive': JsonBoolean(true),
          'scores': JsonArray([JsonNumber(85), JsonNumber(92), JsonNumber(78)]),
          'address': JsonObject({
            'street': JsonString('123 Main St'),
            'city': JsonString('New York'),
            'country': JsonString('USA'),
          }),
          'tags': JsonArray([JsonString('developer'), JsonString('engineer')]),
          'preferences': JsonArray(
            [JsonBoolean(true), JsonBoolean(false), JsonBoolean(true)],
          ),
          'status': JsonNull(),
        }),
      );
    });
  });

  group('Unit Tests', () {
    test('Some/None', () {
      expect(const JsonString('').isSome, true);
      expect(const JsonString('').isNone, false);
      expect(const JsonString('a').isSome, true);
      expect(const JsonString('a').isNone, false);
      expect(const JsonNumber(0).isSome, true);
      expect(const JsonNumber(0).isNone, false);
      expect(const JsonNumber(1).isSome, true);
      expect(const JsonNumber(1).isNone, false);
      expect(const JsonBoolean(false).isSome, true);
      expect(const JsonBoolean(false).isNone, false);
      expect(const JsonBoolean(true).isSome, true);
      expect(const JsonBoolean(true).isNone, false);
      expect(const JsonArray([]).isSome, true);
      expect(const JsonArray([]).isNone, false);
      expect(const JsonObject({}).isSome, true);
      expect(const JsonObject({}).isNone, false);
      expect(const JsonNull().isSome, false);
      expect(const JsonNull().isNone, true);
      expect(const Undefined().isSome, false);
      expect(const Undefined().isNone, true);
      expect(WrongType(wrongTypeValue: 'a').isSome, true);
      expect(WrongType(wrongTypeValue: 'a').isNone, false);
    });

    group('JsonValue', () {
      test('fromJson creates JsonString for string value', () {
        const json = 'hello';
        final jsonValue = JsonValue.fromJson(json);
        expect(jsonValue, isA<JsonString>());
        expect((jsonValue as JsonString).value, equals(json));
      });

      test('fromJson creates JsonNumber for integer value', () {
        const json = 42;
        final jsonValue = JsonValue.fromJson(json);
        expect(jsonValue, isA<JsonNumber>());
        expect((jsonValue as JsonNumber).value, equals(json));
      });

      test('fromJson creates JsonNumber for double value', () {
        const json = 3.14;
        final jsonValue = JsonValue.fromJson(json);
        expect(jsonValue, isA<JsonNumber>());
        expect((jsonValue as JsonNumber).value, equals(json));
      });

      test('fromJson creates JsonBoolean for boolean value', () {
        const json = true;
        final jsonValue = JsonValue.fromJson(json);
        expect(jsonValue, isA<JsonBoolean>());
        expect((jsonValue as JsonBoolean).value, equals(json));
      });

      test('fromJson creates JsonArray for list value', () {
        final json = [1, 'two', true];
        final jsonValue = JsonValue.fromJson(json);
        expect(jsonValue, isA<JsonArray>());
        expect((jsonValue as JsonArray).value, hasLength(3));
        expect(jsonValue.value[0], isA<JsonNumber>());
        expect(jsonValue.value[1], isA<JsonString>());
        expect(jsonValue.value[2], isA<JsonBoolean>());
      });

      test('fromJson creates JsonObject for map value', () {
        final json = {'name': 'John', 'age': 30};
        final jsonValue = JsonValue.fromJson(json) as JsonObject;

        expect(jsonValue.fields.length, 2);
        expect(jsonValue['name'], isA<JsonString>());
        expect(jsonValue['age'], isA<JsonNumber>());
      });

      test('fromJson throws ArgumentError for unknown type', () {
        final json = DateTime.now();
        expect(() => JsonValue.fromJson(json), throwsArgumentError);
      });
    });

    group('JsonString', () {
      test('value returns the correct string', () {
        const value = 'hello';
        const jsonString = JsonString(value);
        expect(jsonString.value, equals(value));
      });
    });

    group('JsonNumber', () {
      test('value returns the correct integer', () {
        const value = 42;
        const jsonNumber = JsonNumber(value);
        expect(jsonNumber.value, equals(value));
      });

      test('value returns the correct double', () {
        const value = 3.14;
        const jsonNumber = JsonNumber(value);
        expect(jsonNumber.value, equals(value));
      });
    });

    group('JsonBoolean', () {
      test('value returns the correct boolean value', () {
        const value = true;
        const jsonBoolean = JsonBoolean(value);
        expect(jsonBoolean.value, equals(value));
      });
    });

    group('JsonArray', () {
      test('value returns the correct list of JsonValues', () {
        final value = [
          const JsonString('one'),
          const JsonNumber(2),
          const JsonBoolean(true),
        ];
        final jsonArray = JsonArray(value);
        expect(jsonArray.value, equals(value));
      });
    });

    group('JsonNull', () {
      test('constructor creates an instance of JsonNull', () {
        const jsonNull = JsonNull();
        expect(jsonNull, isA<JsonNull>());
      });
    });

    group('JsonObject', () {
      test('value returns the correct map of JsonValues', () {
        final value = {
          'name': const JsonString('John'),
          'age': const JsonNumber(30),
        };
        final jsonObject = JsonObject(value);
        expect(jsonObject, equals(JsonObject(value)));
      });
    });
  });
}
