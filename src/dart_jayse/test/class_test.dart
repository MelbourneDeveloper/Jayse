// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:convert';

import 'package:jayse/json_value.dart';
import 'package:test/test.dart';

enum Relationship { recipient, sender }

class Message {
  Message(this._jsonObject);

  final JsonObject _jsonObject;

  Definable<String> get message => _jsonObject.getValue<String>('message');

  JsonObject setMessage(String? message) => _jsonObject.update(
        'message',
        message == null ? const JsonNull() : JsonString(message),
      );

  Definable<bool> get isGood => _jsonObject.getValue<bool>('isGood');

  Definable<List<Person>> get people =>
      switch (_jsonObject.getValue<JsonArray>('people')) {
        (final Defined<JsonArray> ja)
            when ja.definedValue!.value.every((jv) => jv is JsonObject) =>
          Defined(
            ja.definedValue!.value
                .map((jo) => Person(jo as JsonObject))
                .toList(),
          ),
        _ => const Undefined<List<Person>>(),
      };
}

class Person {
  // ignore: unreachable_from_main
  Person(this._jsonObject);

  final JsonObject _jsonObject;

  Definable<String> get name => _jsonObject.getValue<String>('name');

  Definable<Relationship> get type =>
      switch (_jsonObject.getValue<String>('type')) {
        (final Defined<String> defined)
            when defined.definedValue == 'recipient' =>
          Defined(Relationship.recipient),
        (final Defined<String> defined) when defined.definedValue == 'sender' =>
          Defined(Relationship.sender),
        _ => const Undefined(),
      };
}

void main() {
  test('Classes E2E', () async {
    const json = '''{"message":"Hello, World!","isGood":"true",'''
        '"people":[{"name":"jim","type":"recipient"},'
        '{"name":"bob","type":"sender"}]}';

    //Wrap the Map in a JsonObject
    final jsonObject = jsonValueDecode(json) as JsonObject;
    final message = Message(jsonObject);

    final people = message.people;
    expect(people.definedValue!.length, 2);

    final first = people.definedValue![0];
    final second = people.definedValue![1];

    //Basic strongly typed path access with class properties and methods
    expect(message.message.equals('Hello, World!'), isTrue);
    expect(
      first.type.equals(Relationship.recipient),
      isTrue,
    );
    expect(first.name.equals('jim'), isTrue);
    expect(second.name.definedValue, 'bob');

    //Ensure we can access a value where the type is incorrect
    expect(message.isGood.value, const JsonString('true'));

    // Non-destructive mutation on the message field
    final updatedMessage = Message(message.setMessage('newmessage'));
    expect(updatedMessage.message.equals('newmessage'), isTrue);

    //Ensure the original object is not mutated
    expect(message.message.equals('Hello, World!'), isTrue);

    //This ensures there is no loss from the original JSON
    expect(jsonEncode(jsonObject.toJson()), json);

    expect(
      jsonEncode(updatedMessage._jsonObject.toJson()),
      '''{"isGood":"true","people":[{"name":"jim","type":"recipient"},{"name":"bob","type":"sender"}],"message":"newmessage"}''',
    );
  });
}
