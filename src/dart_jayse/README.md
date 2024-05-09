# Jayse

![Logo](https://github.com/MelbourneDeveloper/Jayse/raw/main/Images/IconSmall.png) 

Lossless conversion of JSON to and from statically-typed, immutable objects in Dart.

<small>**Note**: this repo has two separate libraries (Dart/.NET) for working with JSON with the same name. They are currently different, but the aim for the long term is to bring them together and make them converge. See the readme for both [here](../../README.md)</small>

[C# Package](../dotnet/)

## Getting Started

There is no code generation, and there are no external dependencies. Just add the package to your `pubspec.yaml` file.

You can convert a JSON string to a `JsonObject` and access values like this:

```dart
import 'package:jayse/jayse.dart';

void main() {
  final jsonString = '{"name": "John Doe", "age": 30}';
  final jsonObject = JsonObject.fromJson(jsonString);

  final name = jsonObject.value('name');
  final age = jsonObject.value('age');

  print('Name: $name, Age: $age');
}
```

## Features

- **Lossless Conversion**: convert to strongly typed Dart objects and back to JSON without any information loss. See below for more information.
- **Strong Typing**: all values are strongly typed. No accessing `dynamic` values.
- **Immutable**: All objects are immutable. There are no setters. Use non-destructive mutation to create new `JsonObject`s.
- **Simpler data classes and less code generation**: data classes are simpler and code generation with tools like `json_serializable` is often not necessary.

Example:
```dart
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
}
```


## What Is It And Why?

Jayse is a Dart library that facilitates safe and lossless conversion of JSON to and from statically-typed, immutable objects. When you receive data from a backend, you can modify it and send it back without destroying other data that arrived in the payload. This is in contrast with packages like `json_serializable` and `freezed`, which can corrupt data when converting JSON to Dart objects and back.

See the overall goal [here](../../README.md).

## The Problem - Data Loss / Corruption

Let's take a look at the two most popular Dart packages for dealing with JSON serialization and some problems that arise with these. Here is a very simple scenario. The JSON payload has three fields: `name`, `age` and `gender`, but the `User` class is missing the `gender` field. Watch what happens to the JSON when we convert to `User` and back to JSON text.

user.dart
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String name;
  final int age;
  @JsonKey(includeIfNull: false)
  final String? email;

  User({
    required this.name,
    required this.age,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

```dart
void main() {
  // Original JSON data
  final jsonString = '{"name": "John Doe", "age": 30, "gender": "male"}';

  // Convert JSON to User object
  final user = User.fromJson(json.decode(jsonString));
  print('User object: $user');

  // Convert User object back to JSON
  final convertedJsonString = json.encode(user.toJson());
  print(convertedJsonString);
}
```

Original JSON:
```json
{"name": "John Doe", "age": 30, "gender": "male"}
```

Output:
```json
{"name":"John Doe","age":30}
```

Notice that the `gender` field was deleted.

Ok, so the `gender` field data was deleted, and that's to be expected because our data model is out of date on the Dart side. We might be able to tolerate that because our working assumption is that the Dart model will always be automatically generated and correct. But, what if we flip this around and convert JSON missing the `gender` field to `User` and back, where `User` has a `gender` field?

```dart
@JsonSerializable()
class User {
  final String name;
  final int age;
  @JsonKey(includeIfNull: false)
  final String? email;
  final String? gender;

  User({
    required this.name,
    required this.age,
    this.email,
    required this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

```dart
void main() {
  // Original JSON data
  final jsonString = '{"name": "John Doe", "age": 30}';

  // Convert JSON to User object
  final user = User.fromJson(json.decode(jsonString));
  print('User object: $user');

  // Convert User object back to JSON
  final convertedJsonString = json.encode(user.toJson());
  print(convertedJsonString);
}
```

Output:

```json
{"name":"John Doe","age":30,"gender":null}
```

Notice that the `gender` field was added with a `null` value. This is a problem because the original JSON did not have a `gender` field. This is corruption. If send this value back to the server, it may set an existing value to `null` even though the original value was not `null`.

### Field Order Preservation

Some code is sensitive to the ordering of fields. For example, if you are using Firestore, the order of fields is important. If you convert JSON to a Dart object and back, the order of fields may change. This can cause problems with Firestore. Jayse preserves field ordering.