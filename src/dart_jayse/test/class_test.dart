// ignore: lines_longer_than_80_chars
// ignore_for_file: missing_whitespace_between_adjacent_strings,, unreachable_from_main, avoid_print

import 'dart:convert';

import 'package:jayse/json_value.dart';
import 'package:test/test.dart';

enum Relationship { recipient, sender }

class Message {
  Message(this._jsonObject);

  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(JsonObject.fromJson(json));

  final JsonObject _jsonObject;

  bool? get isGood => _jsonObject.value('isGood');
  String? get message => _jsonObject.value('message');

  Map<String, dynamic> toJson() => _jsonObject.toJson();

  Message copyWith({
    bool? isGood,
    String? message,
  }) =>
      Message(
        _jsonObject.withUpdates({
          if (isGood != null) 'isGood': isGood.toJsonValue(),
          if (message != null) 'message': message.toJsonValue(),
        }),
      );

  List<Person>? get people => switch (_jsonObject['people']) {
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
    final updatedMessage = message.copyWith(message: 'newmessage');
    expect(updatedMessage.message, 'newmessage');

    //Ensure the original object is not mutated
    expect(message.message, 'Hello, World!');

    //This ensures there is no loss from the original JSON
    expect(jsonEncode(jsonObject.toJson()), json);

    //Verify the JSON got updated
    expect(
      jsonEncode(updatedMessage._jsonObject.toJson()),
      '''{"message":"newmessage","isGood":"true",'''
      '"people":[{"name":"jim","type":"recipient"},'
      '{"name":"bob","type":"sender"}]}',
    );

    //Verify we can correct the value
    final updatedMessage2 = message.copyWith(isGood: false);
    expect(updatedMessage2.isGood, false);

    // ignore: avoid_print
    print(jsonEncode(updatedMessage2._jsonObject.toJson()));

    //Verify the JSON got corrected, and field ordering was maintained
    expect(
      jsonEncode(updatedMessage2._jsonObject.toJson()),
      '''{"message":"Hello, World!","isGood":false,'''
      '"people":[{"name":"jim","type":"recipient"},'
      '{"name":"bob","type":"sender"}]}',
    );
  });

  test('To and From Json 1', () {
    final message = Message.fromJson({
      'message': 'Hello, World!',
      'isGood': true,
    });

    expect(message.isGood, true);

    final updatedMessage = message.copyWith(isGood: false);

    expect(updatedMessage.isGood, false);

    final json = jsonEncode(updatedMessage.toJson());

    expect(json, '''{"message":"Hello, World!","isGood":false}''');
  });

  test('To and From Json 2', () {
    final message = Message.fromJson({
      'message': 'Hello, World!',
      'isGood': true,
    });

    expect(message.isGood, true);

    final updatedMessage = message.copyWith(isGood: false, message: 'test');

    expect(updatedMessage.isGood, false);
    expect(updatedMessage.message, 'test');

    final json = jsonEncode(updatedMessage.toJson());

    expect(json, '''{"message":"test","isGood":false}''');
  });

  test('toString Basic', () {
    final jo = jsonValueDecode('{"name": "John Doe", "age": 30}');

    final name = jo['name'];
    final age = jo['age'];

    expect('Name: $name, Age: $age', "Name: 'John Doe', Age: 30");
  });
}
