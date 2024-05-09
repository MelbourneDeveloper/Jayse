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
  final jo = jsonValueDecode('{"name": "John Doe", "age": 30}');

  final name = jo['name'];
  final age = jo['age'];

  print('Name: $name, Age: $age');
}
```

Output: 
> Name: 'John Doe', Age: 30

But, `name` and `age` are `JsonValue`s. They are strongly typed. There are several ways to access the value, but you can't just cast them to a `String` or `int` because this would involve casting (`as`). Jayse uses [`pattern matching`](https://dart.dev/language/patterns) under the hood and avoids casting where possible. 

The accessors here return a subtype of `JsonValue`, which could be `JsonString`, `JsonNumber`, `JsonBoolean`, `JsonArray`, `JsonObject`, `JsonNull`, or `Undefined`. If you know what the value will be ahead of time, you can access the value like this. It will return `num` or null if the field doesn't exist, or the value is null.

```dart
num? ageValue = age.numericValue;
```

You can also handle values with a [switch expression](https://www.christianfindlay.com/blog/dart-switch-expressions). The important thing to understand about `JsonValue` is that there are only a preset number of subtypes. That means that you will get an analyzer warning/error if you don't handle all the cases in the switch expression. This is good because it forces you to handle all cases, and you won't get an exception from an unhandled case at runtime. This is good for handling cases where the data type might not be what you expect. For example:

```dart
    final ageValue2 = switch (age) {
      (final JsonNumber jn) => jn.value,
      (final JsonString js) => int.tryParse(js.value),
      //TODO: other cases
      //Catch all case...
      _ => null,
    };
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


## What Problem Does It Solve?

Jayse attempts to solve the problem of data loss or corruption when serializing or deserializing JSON in Dart. Jayse facilitates safe and lossless conversion of JSON to and from statically-typed, immutable objects. When you receive data from a backend, you can modify it and send it back without destroying other data that arrived in the payload. This is in contrast with packages like `json_serializable` and `freezed`, which can corrupt data when converting JSON to Dart objects and back.

See the overall goal [here](../../README.md).

Let's take a look at an example problem with the most common Dart package for dealing with JSON serialization `json_serializable`. The same problem occurs with all popular packages like `freezed` and so on. Here is a very simple scenario. The JSON payload has three fields: `name`, `age` and `gender`, but the `User` class is missing the `gender` field. Watch what happens to the JSON when we convert to `User` and back to JSON text.

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