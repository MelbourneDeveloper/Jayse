import 'package:jayse/jayse.dart';
import 'package:jayse/parser.dart';

import 'package:test/test.dart';

void main() {
  test('Basic Property Access', () {
    final jsonValue = jsonValueDecode('''
    {
      "name": "Alice",
      "age": 30
    }
    ''');

    final parser = JsonPathParser(r'$.name');
    final result = parser.parse(jsonValue);

    expect(result.stringValue, 'Alice');
  });

  test('Array Index Access', () {
    final parser = JsonPathParser(r'$.users[1]');
    final result = parser
        .parse(jsonValueDecode('''{"users": ["Alice", "Bob", "Charlie"]}'''));

    expect(result.stringValue, 'Bob');
  });

  test('Deep Property Access', () {
    final jsonValue = jsonValueDecode('''
    {
      "organization": {
        "name": "OpenAI",
        "address": {
          "city": "San Francisco",
          "state": "CA"
        }
      }
    }
    ''');

    final parser = JsonPathParser(r'$.organization.address.city');
    final result = parser.parse(jsonValue);

    expect(result.stringValue, 'San Francisco');
  });

  test('Access Non-Existent Property', () {
    final jsonValue = jsonValueDecode('''
    {
      "name": "Alice",
      "age": 30
    }
    ''');

    final parser = JsonPathParser(r'$.salary');
    final result = parser.parse(jsonValue);

    expect(result, const Undefined());
  });

  test('Root Property Access', () {
    final jsonValue = jsonValueDecode('''
    {
      "name": "Bob"
    }
    ''');

    final parser = JsonPathParser(r'$');
    final result = parser.parse(jsonValue);

    expect(result['name'].stringValue, 'Bob');
  });

  test('Path Test Basic', () async {
    final jsonValue = jsonValueDecode('''{"author": "bob"}''');
    final parser = JsonPathParser(r'$..author');
    expect(parser.parse(jsonValue), const JsonString('bob'));
  });

  test('Path Test', () async {
    final jsonValue = jsonValueDecode('''
  {
    "book": [
      {
        "author": "John Smith",
        "title": "Book 1"
      },
      {
        "author": "Jane Doe",
        "title": "Book 2"
      },
      {
        "author": "Mark Johnson",
        "title": "Book 3"
      }
    ]
  }
  ''');

    final parser = JsonPathParser(r'$..book[2].author');
    final result = parser.parse(jsonValue);

    expect(result, const JsonString('Mark Johnson'));
  });
}
