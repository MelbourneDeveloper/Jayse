// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:convert';

import 'package:jayse/definable.dart';
import 'package:jayse/definable_extensions.dart';
import 'package:jayse/json_object.dart';
import 'package:jayse/json_object_extensions.dart';
import 'package:test/test.dart';

extension MessageExtensions on JsonObject {
  Definable<String> get message => getValue<String>('message');

  JsonObject setMessage(String? message) => update('message', message);

  Definable<bool> get isGood => getValue<bool>('isGood');
  Definable<List<JsonObject>> get people =>
      getValue<List<JsonObject>>('people');
}

extension DefinableMessageExtensions on Definable<JsonObject> {
  Definable<String> get message => switch (definedValue?.message) {
        (final Defined<String> defined) => defined,
        _ => const Undefined<String>(),
      };
}

enum Relationship { recipient, sender }

extension PersonExtensions on JsonObject {
  Definable<String> get name => getValue<String>('name');

  Definable<Relationship> get type => switch (getValue<String>('type')) {
        (final Defined<String> defined)
            when defined.definedValue == 'recipient' =>
          Defined(Relationship.recipient),
        (final Defined<String> defined) when defined.definedValue == 'sender' =>
          Defined(Relationship.sender),
        _ => const Undefined(),
      };
}

extension DefinablePersonExtensions on Definable<JsonObject> {
  Definable<Relationship> get type => switch (definedValue?.type) {
        (final Defined<Relationship> defined) => defined,
        _ => const Undefined<Relationship>(),
      };

  Definable<String> get name => switch (definedValue?.name) {
        (final Defined<String> defined) => defined,
        _ => const Undefined<String>(),
      };
}

void main() {
  test('Test 1', () async {
    final jsonMap = JsonObject({
      'message': 'Hello, World!',
      'isGood': 'true',
    });

    expect(jsonMap.message.definedValue, 'Hello, World!');

    expect(jsonMap.getValue<String>('message'), Defined('Hello, World!'));

    expect(jsonMap.getValue<String>('nothere'), const Undefined<String>());

    expect(
      switch (jsonMap.getValue<bool>('isGood')) {
        (WrongType(wrongTypeValue: final v)) => v,
        _ => null,
      },
      'true',
    );

    final definableBool = jsonMap.getValue<bool>('isGood');
    expect(
      definableBool.value,
      'true',
    );
  });

  test('Test 2', () async {
    final jsonMap = JsonObject({
      'person': {'name': 'jim', 'type': 'recipient'},
    });

    final person =
        jsonMap.getValue<Map<String, dynamic>>('person').map(JsonObject.new)!;

    expect(person.name.definedValue, 'jim');
    expect(person.type.definedValue, Relationship.recipient);

    //The good stuff
    expect(person.type.definedValue, Relationship.recipient);
    expect(person.type.value, Relationship.recipient);
    expect(person.type.equals(Relationship.recipient), isTrue);
  });

  test('Complete Type With a List', () async {
    final jsonObject = JsonObject({
      'message': 'Hello, World!',
      'isGood': 'true',
      'people': [
        {'name': 'jim', 'type': 'recipient'},
        {'name': 'bob', 'type': 'sender'},
      ],
    });

    expect(jsonObject.message.equals('Hello, World!'), isTrue);
    expect(jsonObject.isGood.value, 'true');
    expect(jsonObject.people[0].type.equals(Relationship.recipient), isTrue);
    expect(jsonObject.people.first.name.equals('jim'), isTrue);
    expect(jsonObject.people[1].name.definedValue, 'bob');

    final updatedJsonObject = jsonObject.setMessage('newmessage');
    expect(updatedJsonObject.message.equals('newmessage'), isTrue);
    expect(jsonObject.message.equals('Hello, World!'), isTrue);
  });

  test(
    'Test 4',
    () {
      final map = JsonObject({
        'message': 'Hello, World!',
        'isGood': 'true',
      });

      expect(
        map.message.equals('Hello, World!'),
        isTrue,
      );

      expect(
        map.isGood.value,
        'true',
      );
      expect(
        map.isGood.equals(false),
        false,
      );
      expect(
        map.isGood.equals(true),
        false,
      );

      expect(
        map.toDefinable().message.equals('Hello, World!'),
        isTrue,
      );
    },
  );

  test('Extensions E2E', () async {
    const json = '''{"message":"Hello, World!","isGood":"true",'''
        '"people":[{"name":"jim","type":"recipient"},'
        '{"name":"bob","type":"sender"}]}';

    //Wrap the Map in a JsonObject
    final jsonObject = JsonObject.fromJson(json);

    //Basic strongly typed path access with extension properties and methods
    expect(jsonObject.message.equals('Hello, World!'), isTrue);
    expect(jsonObject.people[0].type.equals(Relationship.recipient), isTrue);
    expect(jsonObject.people.first.name.equals('jim'), isTrue);
    expect(jsonObject.people[1].name.definedValue, 'bob');

    //Ensure we can access a value where the type is incorrect
    expect(jsonObject.isGood.value, 'true');

    // Non destructive mutation on the message field
    final updatedJsonObject = jsonObject.setMessage('newmessage');
    expect(updatedJsonObject.message.equals('newmessage'), isTrue);

    //Ensure the original object is not mutated
    expect(jsonObject.message.equals('Hello, World!'), isTrue);

    //This ensures there is no loss from the original JSON
    expect(jsonEncode(jsonObject.toJson()), json);

    expect(
      jsonEncode(updatedJsonObject.toJson()),
      '''{"isGood":"true","people":[{"name":"jim","type":"recipient"},{"name":"bob","type":"sender"}],"message":"newmessage"}''',
    );
  });

  test('Nested objects', () {
    final jsonObject = JsonObject({
      'person': {
        'name': 'Alice',
        'age': 30,
        'address': {
          'street': '123 Main St',
          'city': 'New York',
          'country': 'USA',
        },
      },
    });

    expect(
      jsonObject
          .getValue<Map<String, dynamic>>('person')
          .map(JsonObject.new)!
          .getValue<String>('name')
          .equals('Alice'),
      isTrue,
    );
    expect(
      jsonObject
          .getValue<Map<String, dynamic>>('person')
          .map(JsonObject.new)!
          .getValue<int>('age')
          .equals(30),
      isTrue,
    );
    expect(
      jsonObject
          .getValue<Map<String, dynamic>>('person')
          .map(JsonObject.new)!
          .getValue<Map<String, dynamic>>('address')
          .map(JsonObject.new)!
          .getValue<String>('street')
          .equals('123 Main St'),
      isTrue,
    );
    expect(
      jsonObject
          .getValue<Map<String, dynamic>>('person')
          .map(JsonObject.new)!
          .getValue<Map<String, dynamic>>('address')
          .map(JsonObject.new)!
          .getValue<String>('city')
          .equals('New York'),
      isTrue,
    );
    expect(
      jsonObject
          .getValue<Map<String, dynamic>>('person')
          .map(JsonObject.new)!
          .getValue<Map<String, dynamic>>('address')
          .map(JsonObject.new)!
          .getValue<String>('country')
          .equals('USA'),
      isTrue,
    );
  });

  test('Nullable values', () {
    final jsonObject = JsonObject({
      'name': 'John',
      'age': null,
      'email': '',
      'phone': null,
    });

    expect(jsonObject.getValue<String>('name').equals('John'), isTrue);
    expect(jsonObject.getValue<int?>('age').equals(null), isTrue);
    expect(jsonObject.getValue<String>('email').equals(''), isTrue);
    expect(jsonObject.getValue<String>('phone').definedValue, null);
  });

  //TODO: Add support for lists of primitive values
  test(
    'List of primitive values',
    () {
      final jsonObject = JsonObject({
        'numbers': [1, 2, 3, 4, 5],
        'names': ['Alice', 'Bob', 'Charlie'],
        'mixed': [1, 'two', true, null],
      });

      expect(
        jsonObject.getValue<List<int>>('numbers').equals([1, 2, 3, 4, 5]),
        isTrue,
      );
      expect(
        jsonObject
            .getValue<List<String>>('names')
            .equals(['Alice', 'Bob', 'Charlie']),
        isTrue,
      );
      expect(
        jsonObject
            .getValue<List<dynamic>>('mixed')
            .equals([1, 'two', true, null]),
        isTrue,
      );
    },
    skip: true,
  );

  test(
    'Complex nested structure',
    () {
      final jsonObject = JsonObject({
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
      });

      expect(jsonObject.getValue<String>('name').equals('John'), isTrue);
      expect(jsonObject.getValue<int>('age').equals(30), isTrue);
      expect(jsonObject.getValue<bool>('married').equals(true), isTrue);
      expect(
        jsonObject
            .getValue<Map<String, dynamic>>('address')
            .map(JsonObject.new)!
            .getValue<String>('street')
            .equals('123 Main St'),
        isTrue,
      );
      expect(
        jsonObject
            .getValue<Map<String, dynamic>>('address')
            .map(JsonObject.new)!
            .getValue<String>('city')
            .equals('New York'),
        isTrue,
      );
      expect(
        jsonObject
            .getValue<Map<String, dynamic>>('address')
            .map(JsonObject.new)!
            .getValue<String>('country')
            .equals('USA'),
        isTrue,
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
        jsonObject.getValue<List<JsonObject>>('children').equals([]),
        isTrue,
      );
      expect(jsonObject.getValue<JsonObject?>('spouse').equals(null), isTrue);
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

      final jsonObject = JsonObject.fromJson(json);

      expect(jsonObject.getValue<String>('name').equals('Alice'), isTrue);
      expect(jsonObject.getValue<int>('age').equals(25), isTrue);
      expect(jsonObject.getValue<String>('city').equals('London'), isTrue);
      expect(
        jsonObject
            .getValue<List<String>>('hobbies')
            .equals(['reading', 'painting']),
        isTrue,
      );
      expect(
        jsonObject
            .getValue<Map<String, dynamic>>('education')
            .map(JsonObject.new)!
            .getValue<String>('degree')
            .equals("Bachelor's"),
        isTrue,
      );
      expect(
        jsonObject
            .getValue<Map<String, dynamic>>('education')
            .map(JsonObject.new)!
            .getValue<String>('major')
            .equals('Computer Science'),
        isTrue,
      );

      final encodedJson = jsonEncode(jsonObject.toJson());
      expect(encodedJson, equals(json.replaceAll(RegExp(r'\s+'), '')));
    },
    skip: true,
  );
}
