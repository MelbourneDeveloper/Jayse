// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:convert';

import 'package:jayse/definable.dart';
import 'package:jayse/definable_extensions.dart';
import 'package:jayse/json_object.dart';
import 'package:test/test.dart';

enum Relationship { recipient, sender }

class Message {
  Message(this._jsonObject);

  final JsonObject _jsonObject;

  Definable<String> get message => _jsonObject.getValue<String>('message');

  JsonObject setMessage(String? message) =>
      _jsonObject.update('message', message);

  Definable<bool> get isGood => _jsonObject.getValue<bool>('isGood');

  Definable<List<JsonObject>> get people =>
      _jsonObject.getValue<List<JsonObject>>('people');
}

class Person {
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
    final jsonObject = JsonObject.fromJson(json);
    final message = Message(jsonObject);

    //Basic strongly typed path access with class properties and methods
    expect(message.message.equals('Hello, World!'), isTrue);
    expect(
      message.people[0].map(Person.new)!.type.equals(Relationship.recipient),
      isTrue,
    );
    expect(message.people.first.map(Person.new)!.name.equals('jim'), isTrue);
    expect(message.people[1].map(Person.new)!.name.definedValue, 'bob');

    //Ensure we can access a value where the type is incorrect
    expect(message.isGood.value, 'true');

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
