import 'dart:convert';

import 'package:jayse/json_value.dart';
import 'package:test/test.dart';

void main() {
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
      expect(jsonValue.value[stringFieldName], isA<JsonString>());
      expect(
        (jsonValue.value[stringFieldName]! as JsonString).value,
        equals(stringFieldValue),
      );

      // Check number field
      expect(jsonValue.value[numberFieldName], isA<JsonNumber>());
      expect(
        (jsonValue.value[numberFieldName]! as JsonNumber).value,
        equals(numberFieldValue),
      );

      // Check boolean field
      expect(jsonValue.value[boolFieldName], isA<JsonBoolean>());
      expect(
        (jsonValue.value[boolFieldName]! as JsonBoolean).value,
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

      final jsonValue = jsonValueDecode(jsonText) as JsonObject;

      // Check string array field
      expect(jsonValue.value[stringArrayFieldName], isA<JsonArray>());
      final stringArray = jsonValue.value[stringArrayFieldName]! as JsonArray;
      expect(stringArray.value, hasLength(stringArrayFieldValue.length));
      for (var i = 0; i < stringArrayFieldValue.length; i++) {
        expect(stringArray.value[i], isA<JsonString>());
        expect(
          (stringArray.value[i] as JsonString).value,
          equals(stringArrayFieldValue[i]),
        );
      }

      // Check number array field
      expect(jsonValue.value[numberArrayFieldName], isA<JsonArray>());
      final numberArray = jsonValue.value[numberArrayFieldName]! as JsonArray;
      expect(numberArray.value, hasLength(numberArrayFieldValue.length));
      for (var i = 0; i < numberArrayFieldValue.length; i++) {
        expect(numberArray.value[i], isA<JsonNumber>());
        expect(
          (numberArray.value[i] as JsonNumber).value,
          equals(numberArrayFieldValue[i]),
        );
      }

      // Check boolean array field
      expect(jsonValue.value[boolArrayFieldName], isA<JsonArray>());
      final boolArray = jsonValue.value[boolArrayFieldName]! as JsonArray;
      expect(boolArray.value, hasLength(boolArrayFieldValue.length));
      for (var i = 0; i < boolArrayFieldValue.length; i++) {
        expect(boolArray.value[i], isA<JsonBoolean>());
        expect(
          (boolArray.value[i] as JsonBoolean).value,
          equals(boolArrayFieldValue[i]),
        );
      }

      // Check that JSON is preserved
      expect(jsonValueEncode(jsonValue), equals(jsonText));
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
      expect(jsonValue.value[personFieldName], isA<JsonObject>());
      final person = jsonValue.value[personFieldName]! as JsonObject;
      expect(person.value['name'], isA<JsonString>());
      expect(
        (person.value['name']! as JsonString).value,
        equals(personFieldValue['name']),
      );
      expect(person.value['age'], isA<JsonNumber>());
      expect(
        (person.value['age']! as JsonNumber).value,
        equals(personFieldValue['age']),
      );
      expect(person.value['isEmployed'], isA<JsonBoolean>());
      expect(
        (person.value['isEmployed']! as JsonBoolean).value,
        equals(personFieldValue['isEmployed']),
      );

      expect(person.value['address'], isA<JsonObject>());
      final address = person.value['address']! as JsonObject;
      expect(address.value['street'], isA<JsonString>());
      expect(
        (address.value['street']! as JsonString).value,
        // ignore: avoid_dynamic_calls
        equals(personFieldValue['address']['street']),
      );
      expect(address.value['city'], isA<JsonString>());
      expect(
        (address.value['city']! as JsonString).value,
        // ignore: avoid_dynamic_calls
        equals(personFieldValue['address']['city']),
      );
      expect(address.value['country'], isA<JsonString>());
      expect(
        (address.value['country']! as JsonString).value,
        // ignore: avoid_dynamic_calls
        equals(personFieldValue['address']['country']),
      );

      // Check company field
      expect(jsonValue.value[companyFieldName], isA<JsonObject>());
      final company = jsonValue.value[companyFieldName]! as JsonObject;
      expect(company.value['name'], isA<JsonString>());
      expect(
        (company.value['name']! as JsonString).value,
        equals(companyFieldValue['name']),
      );
      expect(company.value['founded'], isA<JsonNumber>());
      expect(
        (company.value['founded']! as JsonNumber).value,
        equals(companyFieldValue['founded']),
      );
      expect(company.value['isPublic'], isA<JsonBoolean>());
      expect(
        (company.value['isPublic']! as JsonBoolean).value,
        equals(companyFieldValue['isPublic']),
      );

      // Check that JSON is preserved
      expect(jsonValueEncode(jsonValue), equals(jsonText));
    });
  });

  group('Unit Tests', () {
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
        final jsonValue = JsonValue.fromJson(json);
        expect(jsonValue, isA<JsonObject>());
        expect((jsonValue as JsonObject).value, hasLength(2));
        expect(jsonValue.value['name'], isA<JsonString>());
        expect(jsonValue.value['age'], isA<JsonNumber>());
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
        expect(jsonObject.value, equals(value));
      });
    });
  });
}
