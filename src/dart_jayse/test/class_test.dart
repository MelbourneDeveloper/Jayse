// ignore: lines_longer_than_80_chars
// ignore_for_file: missing_whitespace_between_adjacent_strings,, unreachable_from_main

import 'dart:convert';

import 'package:jayse/json_value.dart';
import 'package:test/test.dart';

enum Relationship { recipient, sender }

class Message {
  Message(this.jsonObject);

  final JsonObject jsonObject;

  String? get message {
    final value = jsonObject.getValue('message');
    return value is JsonString ? value.value : null;
  }

  Message setMessage(String? message) => Message(
        jsonObject.update(
          'message',
          message == null ? const JsonNull() : JsonString(message),
        ),
      );

  bool? get isGood {
    final value = jsonObject.getValue('isGood');
    return value is JsonBoolean ? value.value : null;
  }

  List<Person>? get people => switch (jsonObject.getValue('people')) {
        (final JsonArray ja) when ja.value.every((jv) => jv is JsonObject) =>
          ja.value.map((jv) => Person(jv as JsonObject)).toList(),
        _ => null,
      };
}

class Person {
  Person(this._jsonObject);

  final JsonObject _jsonObject;

  String? get name {
    final value = _jsonObject.getValue('name');
    return value is JsonString ? value.value : null;
  }

  Relationship? get type => switch (_jsonObject.getValue('type')) {
        (final JsonString js) when js.value == 'recipient' =>
          Relationship.recipient,
        (final JsonString js) when js.value == 'sender' => Relationship.sender,
        _ => null,
      };
}

void main() {
  test('Classes E2E', () async {
    const json = '''{"message":"Hello, World!","isGood":"true",'''
        '"people":[{"name":"jim","type":"recipient"},'
        '{"name":"bob","type":"sender"}]}';

    //Wrap the Map in a JsonObject
    final jsonObject = jsonValueDecode(json) as JsonObject;

    //Ensure we can access a value where the type is incorrect
    expect(jsonObject.getValue('isGood'), const JsonString('true'));

    final message = Message(jsonObject);

    final people = message.people!;
    expect(people.length, 2);

    final first = people[0];
    final second = people[1];

    //Basic strongly typed path access with class properties and methods
    expect(message.message, 'Hello, World!');
    expect(
      first.type,
      Relationship.recipient,
    );
    expect(first.name, 'jim');
    expect(second.name, 'bob');

    // Non-destructive mutation on the message field
    final updatedMessage = message.setMessage('newmessage');
    expect(updatedMessage.message, 'newmessage');

    //Ensure the original object is not mutated
    expect(message.message, 'Hello, World!');

    //This ensures there is no loss from the original JSON
    expect(jsonEncode(jsonObject.toJson()), json);

    expect(
      jsonEncode(updatedMessage.jsonObject.toJson()),
      '''{"isGood":"true","people":[{"name":"jim","type":"recipient"},{"name":"bob","type":"sender"}],"message":"newmessage"}''',
    );
  });
}
