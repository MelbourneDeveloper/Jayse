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

  /// Creates a [JsonValue] from a JSON object
  factory JsonValue.fromJson(Object json) => switch (json) {
        final String string => JsonString(string),
        final num number => JsonNumber(number),
        final bool boolean => JsonBoolean(boolean),
        final List<dynamic> list =>
          JsonArray.unmodifiable(list.map(_safeCast).toList()),
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
  /// Creates an instance of [JsonArray]. Note this currently allows for an
  /// mutable list. Use the unmodifiable for runtime immutability.
  /// Warning: mutating this list breaks the hashCode and equality checks.
  const JsonArray(this.value) : super._internal();

  /// Creates an instance of [JsonArray] with an unmodifiable list
  JsonArray.unmodifiable(Iterable<JsonValue> values)
      : value = List.unmodifiable(values),
        super._internal();

  /// The JSON array value. This list is runtime immutable by default.
  /// Attempting to modify the list will result in an exception.
  /// TODO: Make this compile time immutable
  final List<JsonValue> value;

  @override
  int get hashCode => Object.hashAll(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JsonArray &&
          value.length == other.value.length &&
          value.asMap().entries.every(
                (entry) => entry.value == other.value[entry.key],
              ));
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

/// A class that represents a value that is not defined in a [JsonObject]
final class Undefined extends JsonValue {
  /// Creates an instance of [Undefined]
  const Undefined() : super._internal();

  @override
  //Note: We don't specify a type argument here because they may not
  //match. But, regardless of type, undefined is undefined

  bool operator ==(Object other) => other is Undefined;

  //TODO: is there a different option here?
  @override
  int get hashCode => 'Undefined'.hashCode;
}

/// A class that represents a value that is defined in a [JsonObject] but is of
/// the wrong type
final class WrongType extends JsonValue {
  /// Creates an instance of [WrongType]
  WrongType({required this.wrongTypeValue}) : super._internal();

  /// The value that is of the wrong type
  final Object wrongTypeValue;
}

/// A class that represents a JSON object
final class JsonObject extends JsonValue {
  /// Creates an instance of [JsonObject]
  const JsonObject(this.value) : super._internal();

  /// JSON values
  final Map<String, JsonValue> value;

  /// Returns a clone of this object with the key-value replacing the original
  // ignore: avoid_annotating_with_dynamic
  JsonObject update(String key, JsonValue value) {
    final clonedMap = Map<String, JsonValue>.from(this.value)..remove(key);
    clonedMap[key] = value;
    final entries = clonedMap.entries.toList();
    return JsonObject(Map.fromEntries(entries));
  }

  /// Returns the value of the field if it is defined and has the correct type
  T? getValueTyped<T>(String field) => switch (value[field]) {
        (final JsonString jsonString) when T == String => jsonString.value as T,
        (final JsonNumber jsonNumber)
            when T == num ||
                T == int && jsonNumber is int ||
                T == double && jsonNumber is double =>
          jsonNumber.value as T,
        (final JsonBoolean jsonBoolean) when T == bool =>
          jsonBoolean.value as T,
        (final JsonArray jsonArray) when T == JsonArray => jsonArray as T,
        (final JsonArray jsonArray) when T == (List<JsonValue>) =>
          jsonArray.value as T,
        (final JsonObject jsonObject) when T == JsonObject => jsonObject as T,
        //(final JsonNull jsonNull) => jsonNull,
        //(final JsonValue jsonValue) => WrongType(wrongTypeValue: jsonValue),
        (null) => null,
        _ => null,
      };

  /// Get the JSON Value
  JsonValue getValue(String field) => value[field] ?? const Undefined();

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
        Undefined() => null,
        (final WrongType wrongType) => wrongType.wrongTypeValue,
      };

  @override
  int get hashCode => Object.hashAll(value.entries);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JsonObject &&
          value.length == other.value.length &&
          value.keys.every(
            (key) =>
                other.value.containsKey(key) && value[key] == other.value[key],
          ));
}

/// An extension on [JsonValue]
extension JsonValueExtensions on JsonValue {
  /// Returns the value of the field if it is defined and has the correct type
  JsonValue getValue(String field) => this is JsonObject
      ? (this as JsonObject).getValue(field)
      : const Undefined();
}
