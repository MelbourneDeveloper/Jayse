// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:convert';

import 'package:jayse/json_value.dart';
import 'package:test/test.dart';

import 'class_test.dart';

extension MessageExtensions on JsonObject {
  String? get message {
    final value = getValue('message');
    return value is JsonString ? value.value : null;
  }

  Message setMessage(String? message) {
    final jsonObject = update(
      'message',
      message == null ? const JsonNull() : JsonString(message),
    );

    return Message(jsonObject);
  }

  bool? get isGood {
    final value = getValue('isGood');
    return value is JsonBoolean ? value.value : null;
  }

  List<Person>? get people => switch (getValue('people')) {
        (final JsonArray ja) when ja.value.every((jv) => jv is JsonObject) =>
          ja.value.map((jv) => Person(jv as JsonObject)).toList(),
        _ => null,
      };
}

extension PersonExtensions on JsonObject {
  String? get name {
    final value = getValue('name');
    return value is JsonString ? value.value : null;
  }

  Relationship? get type => switch (getValue('type')) {
        (final JsonString js) when js.value == 'recipient' =>
          Relationship.recipient,
        (final JsonString js) when js.value == 'sender' => Relationship.sender,
        _ => null,
      };
}

void main() {
  test('Test 1', () async {
    final jsonMap = JsonValue.fromJson({
      'message': 'Hello, World!',
      'isGood': 'true',
    }) as JsonObject;

    expect(jsonMap.message, 'Hello, World!');

    expect(jsonMap.getValue('message'), const JsonString('Hello, World!'));

    expect(jsonMap.getValue('nothere'), const Undefined());

    final actual = switch (jsonMap.getValue('isGood')) {
      (WrongType(wrongTypeValue: final v)) => v,
      _ => null,
    }! as JsonString;

    expect(
      actual.value,
      'true',
    );

    final jsonString = jsonMap.getValueTyped<String>('isGood');
    expect(
      jsonString,
      'true',
    );
  });

  test('Test 2', () async {
    final jsonMap = JsonValue.fromJson({
      'person': {'name': 'jim', 'type': 'recipient'},
    }) as JsonObject;

    final person = jsonMap.getValueTyped<JsonObject>('person')!;

    expect(person.name, 'jim');
    expect(person.type, Relationship.recipient);
  });

  test('Complete Type With a List', () async {
    final jsonObject = Message(
      JsonValue.fromJson({
        'message': 'Hello, World!',
        'isGood': 'true',
        'people': [
          {'name': 'jim', 'type': 'recipient'},
          {'name': 'bob', 'type': 'sender'},
        ],
      }) as JsonObject,
    );

    expect(jsonObject.message, 'Hello, World!');
    expect(jsonObject.isGood, const JsonString('true'));
    final people = jsonObject.people;
    final first = people![0];
    final second = people[1];
    final relationship = first.type!;
    expect(relationship, Relationship.recipient);
    expect(first.name, 'jim');
    expect(second.name, 'bob');

    final updatedJsonObject = jsonObject.setMessage('newmessage');
    expect(updatedJsonObject.message, 'newmessage');
    expect(jsonObject.message, 'Hello, World!');
  });

  test(
    'Test 4',
    () {
      final map = JsonValue.fromJson({
        'message': 'Hello, World!',
        'isGood': 'true',
      }) as JsonObject;

      expect(
        map.message,
        'Hello, World!',
      );

      expect(
        map.isGood,
        null,
      );

      expect(
        map.message,
        'Hello, World!',
      );
    },
  );

  test('Extensions E2E', () async {
    const json = '''{"message":"Hello, World!","isGood":"true",'''
        '"people":[{"name":"jim","type":"recipient"},'
        '{"name":"bob","type":"sender"}]}';

    //Wrap the Map in a JsonObject
    final jsonObject = jsonValueDecode(json) as JsonObject;

    final people = jsonObject.people!;
    final first = people[0] as JsonObject;
    final second = people[1] as JsonObject;

    //Basic strongly typed path access with extension properties and methods
    expect(jsonObject.message, 'Hello, World!');

    expect(first.type, Relationship.recipient);
    expect(first.name, 'jim');
    expect(second.name, 'bob');

    //Ensure we can access a value where the type is incorrect
    expect(jsonObject.getValue('isGood'), const JsonString('true'));

    // Non destructive mutation on the message field
    final updatedJsonObject = jsonObject.setMessage('newmessage');
    expect(updatedJsonObject.message, 'newmessage');

    //Ensure the original object is not mutated
    expect(jsonObject.message, 'Hello, World!');

    //This ensures there is no loss from the original JSON
    expect(jsonEncode(jsonObject.toJson()), json);

    expect(
      jsonEncode(updatedJsonObject.jsonObject.toJson()),
      '''{"isGood":"true","people":[{"name":"jim","type":"recipient"},{"name":"bob","type":"sender"}],"message":"newmessage"}''',
    );
  });

  test('Nested objects', () {
    final jsonObject = JsonValue.fromJson({
      'person': {
        'name': 'Alice',
        'age': 30,
        'address': {
          'street': '123 Main St',
          'city': 'New York',
          'country': 'USA',
        },
      },
    }) as JsonObject;

    expect(
      jsonObject.getValue('person').getValue('name'),
      const JsonString('Alice'),
    );
    expect(
      jsonObject.getValue('person').getValue('age'),
      const JsonNumber(30),
    );
    expect(
      jsonObject.getValue('person').getValue('address').getValue('street'),
      const JsonString('123 Main St'),
    );
    expect(
      jsonObject.getValue('person').getValue('address').getValue('city'),
      const JsonString('New York'),
    );
    expect(
      jsonObject.getValue('person').getValue('address').getValue('country'),
      const JsonString('USA'),
    );
  });

  test('Nullable values 1', () {
    final jsonObject = JsonValue.fromJson({
      'age': null,
    }) as JsonObject;

    expect(jsonObject.getValue('age') == const JsonNull(), true);
  });

  test('Nullable values 2', () {
    final jsonObject = JsonValue.fromJson({
      'name': 'John',
      'age': null,
      'email': '',
      'phone': null,
    }) as JsonObject;

    expect(jsonObject.getValue('name'), const JsonString('John'));
    expect(jsonObject.getValue('age'), isA<JsonNull>());
    expect(jsonObject.getValue('email'), const JsonString(''));
    expect(jsonObject.getValue('phone'), isA<JsonNull>());
  });

  //TODO: Add support for lists of primitive values
  test(
    'List of primitive values',
    () {
      final jsonObject = JsonValue.fromJson({
        'numbers': [1, 2, 3, 4, 5],
        'names': ['Alice', 'Bob', 'Charlie'],
        'mixed': [1, 'two', true, null],
      }) as JsonObject;

      expect(
        jsonObject
            .getValueTyped<JsonArray>('numbers')!
            .value
            .map((e) => e as num),
        containsAllInOrder([1, 2, 3, 4, 5]),
      );

      expect(
        jsonObject
            .getValueTyped<JsonArray>('names')!
            .value
            .map((e) => (e as JsonString).value),
        containsAllInOrder(['Alice', 'Bob', 'Charlie']),
      );

      throw UnimplementedError('fix this');
      // expect(
      //   jsonObject
      //       .getValue<List<dynamic>>('mixed')
      //       .equals([1, 'two', true, null]),
      //   isTrue,
      // );
    },
    skip: true,
  );

  test(
    'Complex nested structure',
    () {
      final jsonObject = JsonValue.fromJson({
        'name': 'John',
        'age': 30,
        'married': true,
        'address': {
          'street': '123 Main St',
          'city': 'New York',
          'country': 'USA',
        },
        'phoneNumbers': [
          {
            'type': 'home',
            'number': '123-456-7890',
          },
          {
            'type': 'work',
            'number': '987-654-3210',
          },
        ],
        'children': <dynamic>[],
        'spouse': null,
      }) as JsonObject;

      expect(jsonObject.getValueTyped<String>('name'), 'John');
      expect(jsonObject.getValueTyped<int>('age'), 30);
      expect(jsonObject.getValueTyped<bool>('married'), true);
      expect(
        jsonObject.getValue('address').getValue('street'),
        const JsonString('123 Main St'),
      );
      expect(
        jsonObject.getValue('address').getValue('city'),
        const JsonString('New York'),
      );
      expect(
        jsonObject.getValue('address').getValue('country'),
        const JsonString('USA'),
      );
      // expect(
      //   jsonObject
      //       .getValue<List<JsonObject>>('phoneNumbers')[0]
      //       .getValue<String>('type')
      //       .equals('home'),
      //   isTrue,
      // );
      // expect(
      //   jsonObject
      //       .getValue<List<JsonObject>>('phoneNumbers')[0]
      //       .getValue<String>('number')
      //       .equals('123-456-7890'),
      //   isTrue,
      // );
      // expect(
      //   jsonObject
      //       .getValue<List<JsonObject>>('phoneNumbers')[1]
      //       .getValue<String>('type')
      //       .equals('work'),
      //   isTrue,
      // );
      // expect(
      //   jsonObject
      //       .getValue<List<JsonObject>>('phoneNumbers')[1]
      //       .getValue<String>('number')
      //       .equals('987-654-3210'),
      //   isTrue,
      // );
      expect(
        jsonObject.getValueTyped<JsonArray>('children'),
        isA<JsonArray>(),
      );
      expect(jsonObject.getValue('spouse'), JsonNull);
    },
    skip: true,
  );

  test(
    'JSON encoding and decoding',
    () {
      const json = '''
    {
      "name": "Alice",
      "age": 25,
      "city": "London",
      "hobbies": ["reading", "painting"],
      "education": {
        "degree": "Bachelor's",
        "major": "Computer Science"
      }
    }
  ''';

      final jsonObject = jsonValueDecode(json) as JsonObject;

      expect(jsonObject.getValueTyped<String>('name'), 'Alice');
      expect(jsonObject.getValueTyped<int>('age'), 25);
      expect(jsonObject.getValueTyped<String>('city'), 'London');
      expect(
        jsonObject.getValueTyped<JsonArray>('hobbies')!.value.map(
              (e) => (e as JsonString).value,
            ),
        containsAllInOrder(['reading', 'painting']),
      );

      expect(
        jsonObject.getValue('education').getValue('degree'),
        const JsonString("Bachelor's"),
      );
      expect(
        jsonObject.getValue('education').getValue('major'),
        const JsonString('Computer Science'),
      );

      final encodedJson = jsonEncode(jsonObject.toJson());
      expect(encodedJson, equals(json.replaceAll(RegExp(r'\s+'), '')));
    },
    skip: true,
  );
}
