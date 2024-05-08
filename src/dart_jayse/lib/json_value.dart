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

/// A class that represents a value that may or may not be defined in a
/// [JsonObject]
sealed class Definable<T> {
  const Definable();

  /// Returns true if this value is defined and is equal to [other]
  bool equals(T other) => this is Defined && value == other;
}

/// A class that represents a value that is not defined in a [JsonObject]
final class Undefined<T> extends Definable<T> {
  /// Creates an instance of [Undefined]
  const Undefined();

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
final class WrongType<T> extends Definable<T> {
  /// Creates an instance of [WrongType]
  WrongType({required this.wrongTypeValue});

  /// The value that is of the wrong type
  final Object wrongTypeValue;
}

/// A class that represents a value that is defined in a [JsonObject] and is
/// of the correct type
final class Defined<T> extends Definable<T> {
  /// Creates an instance of [Defined]
  Defined(this.value);

  /// The value of this instance that may be null
  final T? value;

  @override
  bool operator ==(Object other) => other is Defined<T> && other.value == value;

  @override
  int get hashCode => value?.hashCode ?? 0.hashCode;
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
  Definable<T> getValue<T>(String field) => switch (value[field]) {
        (final JsonString jsonString) when T == String =>
          Defined(jsonString.value as T),
        (final JsonNumber jsonNumber)
            when T == num ||
                T == int && jsonNumber.value is int ||
                T == double && jsonNumber.value is double =>
          Defined(jsonNumber.value as T),
        (final JsonBoolean jsonBoolean) when T == bool =>
          Defined(jsonBoolean.value as T),
        //Is this case necessary?
        (final JsonArray jsonArray) when T == JsonArray =>
          Defined(jsonArray as T),
        (final JsonArray jsonArray) when T == (List<JsonValue>) =>
          Defined(jsonArray.value as T),
        (final JsonObject jsonObject) when T == JsonObject =>
          Defined(jsonObject as T),
        (final JsonNull jsonNull) => Defined(jsonNull as T),
        //Is this right?
        (final JsonValue jsonValue) => WrongType(wrongTypeValue: jsonValue),
        (null) => Undefined<T>(),
      };

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JsonObject &&
          value.length == other.value.length &&
          value.keys.every(
            (key) =>
                other.value.containsKey(key) && value[key] == other.value[key],
          ));
}

/// Extension methods for [Definable]
extension DefinableExtensions<T> on Definable<T> {
  /// Returns the defined value if it is defined and has the correct type,
  /// TODO: this looks wrong and requires some serious testing
  Definable<T> getValue(String field) => switch (this) {
        (final Defined<JsonObject> defined) =>
          defined.value?.getValue<T>(field) ?? Undefined<T>(),
        (final Undefined<T> undefined) => undefined as Definable<T>,
        (final WrongType<T> wrongType) => wrongType as Definable<T>,
        _ => Undefined<T>() as Definable<T>,
      };

  /// Returns the defined value if it is defined and has the correct type,
  /// otherwise returns null
  T? get definedValue => switch (this) {
        Defined<T>(value: final val) => val,
        Undefined() => null,
        WrongType() => null,
      };

  /// Returns value if it is defined, but without strong typing, and
  /// without any distinction between null and undefined
  Object? get value => switch (this) {
        Defined<T>(value: final val) => val,
        Undefined() => null,
        (final WrongType<T> wt) => wt.wrongTypeValue,
      };

  /// Allows you to map the defined value to a new value or returns null
  R? map<R>(R Function(T) f) =>
      definedValue != null ? f(definedValue as T) : null;
}

/*
/// Extension methods for [Definable]s that contain [JsonObject]s
extension ListExtensions on Definable<JsonArray> {
  /// Returns the defined value if it is defined and has the correct type,
  Definable<JsonValue> operator [](int index) => switch (this) {
        (final Defined<JsonArray> array) => Defined(array.value?[index]),
        //TODO: this ain't right
        _ => const Undefined<JsonValue>(),
      };

  /// Returns the first element of the defined value if it is defined and has
  Definable<JsonObject> get first => switch (this) {
        (final Defined<List<JsonObject>> defined)
            when defined.value?.isNotEmpty ?? false =>
          Defined(defined.value?.first),
        //TODO: this ain't right
        _ => const Undefined(),
      };
}
*/

/// Extension methods for [JsonObject]
extension JsonObjectExtensions on JsonObject {
  /// Returns a [Definable] of the object
  Definable<JsonObject> toDefinable() => Defined(this);
}
