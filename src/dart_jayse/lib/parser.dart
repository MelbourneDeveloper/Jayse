// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:jayse/jayse.dart';

class JsonPathParser {
  JsonPathParser(this.jsonPath);

  final String jsonPath;

  int _index = 0;

  JsonValue parse(JsonValue rootValue) {
    log('Parsing JSON path', rootValue);
    if (jsonPath.isEmpty) {
      log('JSON path is empty, returning root value', 'N/A');
      return rootValue;
    }

    if (jsonPath[0] != r'$') {
      throw const FormatException(r'JSON path must start with "$"');
    }

    _index = 1;
    final result = _parseExpression(rootValue);
    log('ParseExpression Result', result);
    return result;
  }

  JsonValue _parseExpression(JsonValue value) {
    log('Parsing expression', value);
    if (_index >= jsonPath.length) {
      log('Reached end of JSON path and returning value', value);
      return value;
    }

    if (jsonPath[_index] == '.') {
      _incrementIndex();
      if (_index >= jsonPath.length) {
        throw const FormatException('Invalid JSON path syntax');
      }
      if (jsonPath[_index] == '.') {
        _incrementIndex();
        final result = _parseRecursiveDescent(value);
        log('Recursive descent result', result);
        return result;
      } else {
        return _parseDotNotation(value);
      }
    } else if (jsonPath[_index] == '[') {
      _incrementIndex();
      return _parseBracketNotation(value);
    } else if (jsonPath[_index] == '*') {
      _incrementIndex();
      return _parseWildcard(value);
    } else {
      return _parseDotNotation(value);
    }
  }

  JsonValue _parseDotNotation(JsonValue value) {
    log('Parsing dot notation', value);
    if (_index >= jsonPath.length) {
      // We've reached the end of the JSON path, so return the value
      log('Reached end of JSON path, returning value', value);
      return value;
    }

    if (value is! JsonObject) {
      //Is the code going wrong here?

      log('Value is not a JsonObject, returning Undefined', value);
      return const Undefined();
    }

    final fieldName = _parseFieldName();

    return _parseExpression(value[fieldName]);
  }

  JsonValue _parseBracketNotation(JsonValue value) {
    log('Parsing bracket notation', value);
    if (jsonPath[_index] == "'") {
      _incrementIndex();
      final fieldName = _parseQuotedFieldName();
      log('Parsed quoted field name: $fieldName', value);
      _expectChar(']');
      return _parseExpression(value[fieldName]);
    } else if (jsonPath[_index] == '*') {
      _incrementIndex();
      _expectChar(']');

      return _parseWildcard(value);
    } else {
      final index = _parseIndex();
      log('Parsed index: $index', value);
      _expectChar(']');
      if (value is JsonArray) {
        log('Accessing array element at index: $index', value);
        return _parseExpression(value.value[index]);
      } else {
        log('Value is not a JsonArray, returning Undefined', value);
        return const Undefined();
      }
    }
  }

  JsonValue _parseWildcard(JsonValue value) {
    log('Parsing wildcard', value);
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
      _incrementIndex();
    }
    return buffer.toString();
  }

  String _parseQuotedFieldName() {
    final buffer = StringBuffer();
    while (_index < jsonPath.length && jsonPath[_index] != "'") {
      buffer.write(jsonPath[_index]);
      _incrementIndex();
    }
    _expectChar("'");
    return buffer.toString();
  }

  int _parseIndex() {
    final buffer = StringBuffer();
    while (_index < jsonPath.length && _isDigit(jsonPath[_index])) {
      buffer.write(jsonPath[_index]);
      _incrementIndex();
    }
    return int.parse(buffer.toString());
  }

  JsonValue _parseRecursiveDescent(JsonValue value) {
    log('Parsing recursive descent', value);

    if (value is JsonObject) {
      if (_index < jsonPath.length && jsonPath[_index] == '[') {
        _incrementIndex();
        return _parseBracketNotation(value);
      } else {
        final fieldName = _parseFieldName();
        final result = _parseRecursiveDescent(value.getValue(fieldName));
        if (result is! Undefined) {
          return result;
        }
        return const Undefined();
      }
    } else if (value is JsonArray) {
      if (_index < jsonPath.length && jsonPath[_index] == '[') {
        _incrementIndex();
        return _parseBracketNotation(value);
      } else {
        return const Undefined();
      }
    } else {
      // Return the scalar value itself
      log('Returning scalar value', value);
      return value;
    }
  }

  bool _isUnquotedFieldChar(String char) =>
      RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(char);

  bool _isDigit(String char) => RegExp(r'^\d+$').hasMatch(char);

  void _expectChar(String expected) {
    if (_index >= jsonPath.length || jsonPath[_index] != expected) {
      throw FormatException('Expected "$expected"');
    }
    _incrementIndex();
  }

  void log(String step, Object value) =>
      // ignore: avoid_print
      print('Step: $step. Path: '
          '${_currentPath()} of $jsonPath '
          'Index: $_index Value: $value');

  String _currentPath() =>
      jsonPath.substring(0, min(jsonPath.length - 1, _index));

  bool _incrementIndex() {
    _index++;
    return _index < jsonPath.length;
  }
}
