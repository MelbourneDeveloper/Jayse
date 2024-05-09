// ignore_for_file: public_member_api_docs, avoid_print

import 'package:jayse/jayse.dart';

class JsonPathParser {
  JsonPathParser(this.jsonPath);
  final String jsonPath;
  int _index = 0;

  JsonValue parse(JsonValue rootValue) {
    print('Parsing JSON path: $jsonPath');
    if (jsonPath.isEmpty) {
      print('JSON path is empty, returning root value');
      return rootValue;
    }

    if (jsonPath[0] != r'$') {
      throw const FormatException(r'JSON path must start with "$"');
    }

    _index = 1;
    print('Starting parsing at index: $_index');
    final result = _parseExpression(rootValue);
    print('Parsing completed, result: $result');
    return result;
  }

  JsonValue _parseExpression(JsonValue value) {
    print('Parsing expression at index: $_index');
    if (_index >= jsonPath.length) {
      print('Reached end of JSON path, returning value: $value');
      return value;
    }

    if (jsonPath[_index] == '.') {
      _index++;
      if (_index >= jsonPath.length) {
        throw const FormatException('Invalid JSON path syntax');
      }
      if (jsonPath[_index] == '.') {
        _index++;
        print('Parsing recursive descent at index: $_index');
        final result = _parseRecursiveDescent(value);
        print('Recursive descent result: $result');
        return result;
      } else {
        print('Parsing dot notation at index: $_index');
        return _parseDotNotation(value);
      }
    } else if (jsonPath[_index] == '[') {
      _index++;
      print('Parsing bracket notation at index: $_index');
      return _parseBracketNotation(value);
    } else if (jsonPath[_index] == '*') {
      _index++;
      print('Parsing wildcard at index: $_index');
      return _parseWildcard(value);
    } else {
      print('Parsing field name at index: $_index');
      return _parseDotNotation(value);
    }
  }

  JsonValue _parseDotNotation(JsonValue value) {
    print('Parsing dot notation for value: $value');
    if (value is! JsonObject) {
      print('Value is not a JsonObject, returning Undefined');
      return const Undefined();
    }

    final fieldName = _parseFieldName();
    print('Parsed field name: $fieldName');
    return _parseExpression(value[fieldName]);
  }

  JsonValue _parseBracketNotation(JsonValue value) {
    print('Parsing bracket notation for value: $value');
    if (jsonPath[_index] == "'") {
      _index++;
      final fieldName = _parseQuotedFieldName();
      print('Parsed quoted field name: $fieldName');
      _expectChar(']');
      return _parseExpression(value[fieldName]);
    } else if (jsonPath[_index] == '*') {
      _index++;
      _expectChar(']');
      print('Parsing wildcard in bracket notation');
      return _parseWildcard(value);
    } else {
      final index = _parseIndex();
      print('Parsed index: $index');
      _expectChar(']');
      if (value is JsonArray) {
        print('Accessing array element at index: $index');
        return _parseExpression(value.value[index]);
      } else {
        print('Value is not a JsonArray, returning Undefined');
        return const Undefined();
      }
    }
  }

  JsonValue _parseWildcard(JsonValue value) {
    if (value is JsonObject) {
      final values = value.fields
          .map((field) => _parseExpression(value.getValue(field)))
          .toList();
      return JsonArray(values);
    } else if (value is JsonArray) {
      final values = value.value.map(_parseExpression).toList();
      return JsonArray(values);
    } else {
      return const Undefined();
    }
  }

  String _parseFieldName() {
    final buffer = StringBuffer();
    while (_index < jsonPath.length && _isUnquotedFieldChar(jsonPath[_index])) {
      buffer.write(jsonPath[_index]);
      _index++;
    }
    return buffer.toString();
  }

  String _parseQuotedFieldName() {
    final buffer = StringBuffer();
    while (_index < jsonPath.length && jsonPath[_index] != "'") {
      buffer.write(jsonPath[_index]);
      _index++;
    }
    _expectChar("'");
    return buffer.toString();
  }

  int _parseIndex() {
    final buffer = StringBuffer();
    while (_index < jsonPath.length && _isDigit(jsonPath[_index])) {
      buffer.write(jsonPath[_index]);
      _index++;
    }
    return int.parse(buffer.toString());
  }

JsonValue _parseRecursiveDescent(JsonValue value) {
    print('Parsing recursive descent for value: $value');
    if (value is JsonObject) {
      final values = value.fields
          .map((field) => _parseRecursiveDescent(value.getValue(field)))
          .where((value) => value is! Undefined)
          .toList();
      return JsonArray(values);
    } else if (value is JsonArray) {
      final values = value.value
          .map(_parseRecursiveDescent)
          .where((value) => value is! Undefined)
          .toList();
      return JsonArray(values);
    } else {
      return _parseExpression(value);
    }
  }

  bool _isUnquotedFieldChar(String char) =>
      RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(char);

  bool _isDigit(String char) => RegExp(r'^\d+$').hasMatch(char);

  void _expectChar(String expected) {
    if (_index >= jsonPath.length || jsonPath[_index] != expected) {
      throw FormatException('Expected "$expected"');
    }
    _index++;
  }
}
