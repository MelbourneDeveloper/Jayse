/// A class that represents a JSON value
sealed class JsonValue {
  /// Creates an instance of [JsonValue]
  const JsonValue._internal();
}

/// A class that represents a JSON string
final class JsonString extends JsonValue {
  /// Creates an instance of [JsonString]
  const JsonString(this.value) : super._internal();

  /// The JSON string value
  final String value;
}

/// A class that represents a JSON number
final class JsonNumber extends JsonValue {
  /// Creates an instance of [JsonNumber]
  const JsonNumber(this.value) : super._internal();

  /// The JSON number value
  final num value;
}

/// A class that represents a JSON boolean
final class JsonBoolean extends JsonValue {
  /// Creates an instance of [JsonBoolean]
  const JsonBoolean(this.value) : super._internal();

  /// The JSON boolean value
  final bool value;
}

/// A class that represents a JSON array
final class JsonArray extends JsonValue {
  /// Creates an instance of [JsonArray]
  const JsonArray(this.value) : super._internal();

  /// The JSON array value
  final List<JsonValue> value;
}

/// A class that represents a JSON null
final class JsonNull extends JsonValue {
  /// Creates an instance of [JsonNull]
  const JsonNull() : super._internal();
}

/// A class that represents a JSON object
final class JsonObject extends JsonValue {
  /// Creates an instance of [JsonObject]
  const JsonObject(this.value) : super._internal();

  /// JSON values
  final Map<String, JsonValue> value;
}
