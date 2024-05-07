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

      // Check encoding
      expect(
        jsonValueEncode(jsonValue),
        equals(
          '{"$stringFieldName":"$stringFieldValue","$numberFieldName":'
          '$numberFieldValue,"$boolFieldName":$boolFieldValue}',
        ),
      );
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
