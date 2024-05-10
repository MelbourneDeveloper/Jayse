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
        final Map<String, dynamic> map => map.toJsonValue(),
        _ =>
          throw ArgumentError('Unknown JSON value type: ${json.runtimeType}'),
      };

  @override
  String toString() => switch (this) {
        (final JsonString jsonString) => "'${jsonString.value}'",
        (final JsonNumber jsonNumber) => jsonNumber.value.toString(),
        (final JsonBoolean jsonBoolean) => jsonBoolean.value.toString(),
        (final JsonArray jsonArray) =>
          jsonArray.value.map((e) => e.toString()).join(', '),
        (final JsonObject jsonObject) => jsonValueEncode(jsonObject),
        JsonNull() => 'JsonNull',
        Undefined() => 'Undefined',
        (final WrongType wrongType) => 'WrongType(${wrongType.wrongTypeValue})',
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
  const JsonObject(this._value) : super._internal();

  /// Creates an instance of [JsonObject] from a JSON map
  factory JsonObject.fromJson(Map<String, dynamic> json) => json.toJsonValue();

  /// JSON values
  final Map<String, JsonValue> _value;

  /// Returns a clone of this object with the key-value pairs replacing the
  /// original values
  JsonObject withUpdates(Map<String, JsonValue> updates) {
    var jo = this;
    //Note: performance here could be improved by merging these
    for (final entry in updates.entries) {
      jo = jo.withUpdate(entry.key, entry.value);
    }
    return jo;
  }

  /// Returns a clone of this object with the key-value replacing the original
  /// Note: this preserves field ordering
  JsonObject withUpdate(String key, JsonValue value) {
    final entries = _value.entries.toList();
    var replaced = false;
    for (var i = _value.entries.length - 1; i >= 0; i--) {
      final entry = entries[i];
      if (entry.key == key) {
        entries
          ..removeAt(i)
          ..insert(i, MapEntry(key, value));
        replaced = true;
        break;
      }
    }

    if (!replaced) entries.insert(entries.length - 1, MapEntry(key, value));

    return JsonObject(Map.fromEntries(entries));
  }

  /// Returns the value of the field if it is defined and has the correct type
  T? value<T>(String field) => switch (_value[field]) {
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
  //JsonValue operator [](String field) => _value[field] ?? const Undefined();

  /// Available fields
  Iterable<String> get fields => _value.keys;

  /// Converts the [JsonObject] to a JSON-compatible map.
  Map<String, dynamic> toJson() => _value
      .map((key, jsonValue) => MapEntry(key, _jsonValueToJson(jsonValue)));

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
  int get hashCode => Object.hashAll(_value.entries);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JsonObject &&
          _value.length == other._value.length &&
          _value.keys.every(
            (key) =>
                other._value.containsKey(key) &&
                _value[key] == other._value[key],
          ));
}

/// An extension on [JsonObject]
extension JsonObjectExtensions on JsonObject {

  /// Returns the value of the field if it is defined. For performance reasons,
  /// it's better to grab the value directly from the accessor and use the value
  bool containsKey(String fieldName) => this[fieldName] != const Undefined();
}

/// An extension on [JsonValue]
extension JsonValueExtensions on JsonValue {
  /// Returns the value of the field if this is a JSON object
  JsonValue operator [](String field) => switch (this) {
        (final JsonObject jo) when jo._value[field] != null =>
          jo._value[field]!,
        _ => const Undefined()
      };

  /// Returns the value or null
  String? get stringValue =>
      this is JsonString ? (this as JsonString).value : null;

  /// Returns the value or null
  num? get numericValue =>
      this is JsonNumber ? (this as JsonNumber).value : null;

  /// Returns the value or null
  JsonObject? get objectValue => this is JsonObject ? this as JsonObject : null;

  /// Returns the value or null
  bool? get booleanValue =>
      this is JsonBoolean ? (this as JsonBoolean).value : null;

  /// Returns the value or null
  int? get integerValue => switch (this) {
        (final JsonNumber jn) when jn.value is int => jn.value as int,
        _ => null,
      };

  /// Returns the value or null
  DateTime? get dateTimeValue => switch (this) {
        (final JsonString js) => DateTime.tryParse(js.value),
        _ => null,
      };

  /// Returns the value of the field if it is defined and has the correct type
  JsonValue getValue(String field) =>
      this is JsonObject ? (this as JsonObject)[field] : const Undefined();
}

/// An extension on [bool] for [JsonValue]
extension BoolExtensions on bool? {
  /// Converts a [bool] to a [JsonValue]
  JsonValue toJsonValue() =>
      this == null ? const JsonNull() : JsonBoolean(this!);
}

/// An extension on [String] for [JsonValue]
extension StringExtensions on String? {
  /// Converts a [String] to a [JsonValue]
  JsonValue toJsonValue() =>
      this == null ? const JsonNull() : JsonString(this!);
}

/// An extension on [Map<String, dynamic>] for [JsonObject]
extension MapExtensions on Map<String, dynamic> {
  /// Converts a [Map<String, dynamic>] to a [JsonObject]
  JsonObject toJsonValue() =>
      JsonObject(map((key, value) => MapEntry(key, _safeCast(value))));
}
