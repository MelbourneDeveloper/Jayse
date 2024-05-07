# Jayse

![Logo](Images/IconSmall.png) 

Lossless conversion of JSON to and from statically-typed, immutable objects in Dart.

<small>**Note**: this repo has two separate libraries (Dart/.NET) for working with JSON with the same name. They are currently different, but the aim for the long term is to bring them together and make them converge. See the readme for both [here](../../README.md)</small>

[C# Package](../dotnet/)

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