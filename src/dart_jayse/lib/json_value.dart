import 'dart:convert';

/// Decodes a JSON string into a [JsonValue]
JsonValue jsonValueDecode(String value) =>
    JsonValue.fromJson(jsonDecode(value) as Object);

/// Encodes a [JsonValue] into a JSON string
String jsonValueEncode(JsonObject value) => jsonEncode(value.toJson());

/// A class that represents a JSON value
sealed class JsonValue {
  /// Creates an instance of [JsonValue]
  const JsonValue._internal();

  factory JsonValue.fromJson(Object json) => switch (json) {
        final String string => JsonString(string),
        final num number => JsonNumber(number),
        final bool boolean => JsonBoolean(boolean),
        final List<dynamic> list => JsonArray(list.map(_safeCast).toList()),
        final Map<String, dynamic> map =>
          JsonObject(map.map((key, value) => MapEntry(key, _safeCast(value)))),
        _ =>
          throw ArgumentError('Unknown JSON value type: ${json.runtimeType}'),
      };
}

// ignore: avoid_annotating_with_dynamic
JsonValue _safeCast(dynamic value) =>
    value is Object ? JsonValue.fromJson(value) : const JsonNull();

/// A class that represents a JSON string
final class JsonString extends JsonValue {
  /// Creates an instance of [JsonString]
  const JsonString(this.value) : super._internal();

  /// The JSON string value
  final String value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => other is JsonString && other.value == value;
}

/// A class that represents a JSON number
final class JsonNumber extends JsonValue {
  /// Creates an instance of [JsonNumber]
  const JsonNumber(this.value) : super._internal();

  /// The JSON number value
  final num value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => other is JsonNumber && other.value == value;
}

/// A class that represents a JSON boolean
final class JsonBoolean extends JsonValue {
  /// Creates an instance of [JsonBoolean]
  const JsonBoolean(this.value) : super._internal();

  /// The JSON boolean value
  final bool value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is JsonBoolean && other.value == value;
}

/// A class that represents a JSON array
final class JsonArray extends JsonValue {
  /// Creates an instance of [JsonArray]
  JsonArray(Iterable<JsonValue> values)
      : value = List.unmodifiable(values),
        super._internal();

  /// The JSON array value. This list is runtime immutable. Attempting
  /// to modify the list will result in an exception.
  /// TODO: Make this compile time immutable
  final List<JsonValue> value;

  @override
  int get hashCode => Object.hashAll(value);

  @override
  bool operator ==(Object other) => other is JsonArray && other.value == value;
}

/// A class that represents a JSON null
final class JsonNull extends JsonValue {
  /// Creates an instance of [JsonNull]
  const JsonNull() : super._internal();

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) => other is JsonNull;
}

/// A class that represents a JSON object
final class JsonObject extends JsonValue {
  /// Creates an instance of [JsonObject]
  const JsonObject(this.value) : super._internal();

  /// JSON values
  final Map<String, JsonValue> value;

  /// Converts the [JsonObject] to a JSON-compatible map.
  Map<String, dynamic> toJson() =>
      value.map((key, jsonValue) => MapEntry(key, _jsonValueToJson(jsonValue)));

  /// Recursively converts a [JsonValue] to its JSON-compatible representation.
  dynamic _jsonValueToJson(JsonValue jsonValue) => switch (jsonValue) {
        final JsonString jsonString => jsonString.value,
        final JsonNumber jsonNumber => jsonNumber.value,
        final JsonBoolean jsonBoolean => jsonBoolean.value,
        final JsonArray jsonArray =>
          jsonArray.value.map(_jsonValueToJson).toList(),
        final JsonObject jsonObject => jsonObject.toJson(),
        JsonNull() => null,
      };

  @override
  int get hashCode => Object.hashAll(value.entries);

  @override
  bool operator ==(Object other) => other is JsonObject && other.value == value;
}
