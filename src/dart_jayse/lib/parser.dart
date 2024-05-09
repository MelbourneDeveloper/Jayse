// ignore_for_file: public_member_api_docs

import 'package:jayse/jayse.dart';

class JsonPathParser {
  JsonPathParser(this.jsonPath);
  final String jsonPath;
  int _index = 0;

  JsonValue parse(JsonValue rootValue) {
    if (jsonPath.isEmpty) {
      return rootValue;
    }

    if (jsonPath[0] != r'$') {
      throw const FormatException(r'JSON path must start with "$"');
    }

    _index = 1;
    return _parseExpression(rootValue);
  }

  JsonValue _parseExpression(JsonValue value) {
    if (_index >= jsonPath.length) {
      return value;
    }

    if (jsonPath[_index] == '.') {
      _index++;
      return _parseDotNotation(value);
    } else if (jsonPath[_index] == '[') {
      _index++;
      return _parseBracketNotation(value);
    } else if (jsonPath[_index] == '*') {
      _index++;
      return _parseWildcard(value);
    } else {
      throw const FormatException('Invalid JSON path syntax');
    }
  }

  JsonValue _parseDotNotation(JsonValue value) {
    if (value is! JsonObject) {
      return const Undefined();
    }

    final fieldName = _parseFieldName();
    return _parseExpression(value[fieldName]);
  }

  JsonValue _parseBracketNotation(JsonValue value) {
    if (jsonPath[_index] == "'") {
      _index++;
      final fieldName = _parseQuotedFieldName();
      _expectChar(']');
      return _parseExpression(value[fieldName]);
    } else if (jsonPath[_index] == '*') {
      _index++;
      _expectChar(']');
      return _parseWildcard(value);
    } else {
      final index = _parseIndex();
      _expectChar(']');
      if (value is JsonArray) {
        return _parseExpression(value.value[index]);
      } else {
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
