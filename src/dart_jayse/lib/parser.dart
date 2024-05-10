// ignore_for_file: parameter_assignments

import 'package:jayse/jayse.dart';

/// Parses a JSON path expression and returns the corresponding value from the
/// JSON.
JsonValue parseJsonPath(String jsonPath, JsonValue rootValue) {
  if (jsonPath.isEmpty) {
    log('JSON path is empty, returning root value', 'N/A', rootValue);
    return rootValue;
  }

  if (jsonPath[0] != r'$') {
    throw const FormatException(r'JSON path must start with "$"');
  }

  final result = parseExpression(jsonPath, 1, rootValue);
  log('ParseExpression Result', '', result);
  return result;
}

/// Parses a JSON path expression and returns the corresponding value from the
/// JSON.
JsonValue parseExpression(String jsonPath, int index, JsonValue value) {
  log('Parsing expression', jsonPath.substring(0, index), value);
  if (index >= jsonPath.length) {
    log(
      'Reached end of JSON path and returning value',
      jsonPath.substring(0, index),
      value,
    );
    return value;
  }

  if (jsonPath[index] == '.') {
    index++;
    if (index >= jsonPath.length) {
      throw const FormatException('Invalid JSON path syntax');
    }
    if (jsonPath[index] == '.') {
      index++;
      final result = parseRecursiveDescent(jsonPath, index, value);
      log('Recursive descent result', jsonPath.substring(0, index), result);
      return result;
    } else {
      return parseDotNotation(jsonPath, index, value);
    }
  } else if (jsonPath[index] == '[') {
    index++;
    return parseBracketNotation(jsonPath, index, value);
  } else if (jsonPath[index] == '*') {
    index++;
    return parseWildcard(jsonPath, index, value);
  } else {
    return parseDotNotation(jsonPath, index, value);
  }
}

/// Parses a JSON path expression in dot notation and returns the corresponding
JsonValue parseDotNotation(String jsonPath, int index, JsonValue value) {
  log('Parsing dot notation', jsonPath.substring(0, index), value);
  if (index >= jsonPath.length) {
    // We've reached the end of the JSON path, so return the value
    log(
      'Reached end of JSON path, returning value',
      jsonPath.substring(0, index),
      value,
    );
    return value;
  }

  if (value is! JsonObject) {
    log(
      'Value is not a JsonObject, returning Undefined',
      jsonPath.substring(0, index),
      value,
    );
    return const Undefined();
  }

  if (jsonPath[index] == '*') {
    index++;
    return parseWildcard(jsonPath, index, value);
  }

  final fieldName = parseFieldName(jsonPath, index);
  index += fieldName.length;

  final fieldValue = value[fieldName];
  if (fieldValue != const Undefined()) {
    return parseExpression(jsonPath, index, fieldValue);
  } else {
    log(
      'Field not found, returning Undefined',
      jsonPath.substring(0, index),
      value,
    );
    return const Undefined();
  }
}

/// Parses a JSON path expression in bracket notation and returns the
/// corresponding value.
JsonValue parseBracketNotation(String jsonPath, int index, JsonValue value) {
  log('Parsing bracket notation', jsonPath.substring(0, index), value);
  if (jsonPath[index] == "'") {
    index++;
    final fieldName = parseQuotedFieldName(jsonPath, index);
    index += fieldName.length + 1;
    log(
      'Parsed quoted field name: $fieldName',
      jsonPath.substring(0, index),
      value,
    );
    expectChar(jsonPath, index, ']');
    index++;
    return parseExpression(jsonPath, index, value[fieldName]);
  } else if (jsonPath[index] == '*') {
    index++;
    expectChar(jsonPath, index, ']');
    index++;
    return parseWildcard(jsonPath, index, value);
  } else {
    final indexValue = parseIndex(jsonPath, index);
    index += indexValue.toString().length;
    log('Parsed index: $indexValue', jsonPath.substring(0, index), value);
    expectChar(jsonPath, index, ']');
    index++;
    if (value is JsonArray) {
      log(
        'Accessing array element at index: $indexValue',
        jsonPath.substring(0, index),
        value,
      );
      return parseExpression(jsonPath, index, value.value[indexValue]);
    } else {
      log(
        'Value is not a JsonArray, returning Undefined',
        jsonPath.substring(0, index),
        value,
      );
      return const Undefined();
    }
  }
}

/// Parses a JSON path expression with a wildcard and returns the corresponding
JsonValue parseWildcard(String jsonPath, int index, JsonValue value) {
  log('Parsing wildcard', jsonPath.substring(0, index), value);
  if (value is JsonObject) {
    final values = value.fields
        .map((field) => parseExpression(jsonPath, index, value.getValue(field)))
        .toList();
    return JsonArray(values);
  } else if (value is JsonArray) {
    final values = value.value
        .map((item) => parseExpression(jsonPath, index, item))
        .toList();
    return JsonArray(values);
  } else if (value is Undefined) {
    log(
      'Value is Undefined, returning Undefined',
      jsonPath.substring(0, index),
      value,
    );
    return const Undefined();
  } else {
    log(
      'Value is not an object or array, returning Undefined',
      jsonPath.substring(0, index),
      value,
    );
    return const Undefined();
  }
}

/// Parses a field name from a JSON path expression.
String parseFieldName(String jsonPath, int index) {
  final buffer = StringBuffer();
  while (index < jsonPath.length && isUnquotedFieldChar(jsonPath[index])) {
    buffer.write(jsonPath[index]);
    index++;
  }
  return buffer.toString();
}

/// Parses a quoted field name from a JSON path expression.
String parseQuotedFieldName(String jsonPath, int index) {
  final buffer = StringBuffer();
  while (index < jsonPath.length && jsonPath[index] != "'") {
    buffer.write(jsonPath[index]);
    index++;
  }
  expectChar(jsonPath, index, "'");
  return buffer.toString();
}

/// Parses an index from a JSON path expression.
int parseIndex(String jsonPath, int index) {
  final buffer = StringBuffer();
  while (index < jsonPath.length && isDigit(jsonPath[index])) {
    buffer.write(jsonPath[index]);
    index++;
  }
  return int.parse(buffer.toString());
}

/// Parses a JSON path expression with recursive descent and returns the
/// corresponding value.
JsonValue parseRecursiveDescent(String jsonPath, int index, JsonValue value) {
  log('Parsing recursive descent', jsonPath.substring(0, index), value);

  if (value is JsonObject) {
    if (index < jsonPath.length && jsonPath[index] == '[') {
      index++;
      return parseBracketNotation(jsonPath, index, value);
    } else {
      final fieldName = parseFieldName(jsonPath, index);
      index += fieldName.length;
      final result =
          parseRecursiveDescent(jsonPath, index, value.getValue(fieldName));
      if (result is! Undefined) {
        return result;
      }
      return const Undefined();
    }
  } else if (value is JsonArray) {
    if (index < jsonPath.length && jsonPath[index] == '[') {
      index++;
      return parseBracketNotation(jsonPath, index, value);
    } else {
      return const Undefined();
    }
  } else {
    // Return the scalar value itself
    log('Returning scalar value', jsonPath.substring(0, index), value);
    return value;
  }
}

/// Returns `true` if the character is a valid unquoted field character.
bool isUnquotedFieldChar(String char) =>
    RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(char);

/// Returns `true` if the character is a digit.
bool isDigit(String char) => RegExp(r'^\d+$').hasMatch(char);

/// Throws a [FormatException] if the character at the specified index in the
void expectChar(String jsonPath, int index, String expected) {
  if (index >= jsonPath.length || jsonPath[index] != expected) {
    throw FormatException('Expected "$expected"');
  }
}

/// Logs a message with the current step, JSON path, and value.
void log(String step, String currentPath, Object value) =>
    // ignore: avoid_print
    print(
      'Step: $step. Path: $currentPath Value: $value',
    );
