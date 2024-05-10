import 'package:jayse/jayse.dart';
import 'package:jayse/parser.dart';

import 'package:test/test.dart';

void main() {
  group('Implemented Syntax', () {
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

    test('Wildcard with Object', () {
      final jsonValue = jsonValueDecode('''
    {
      "person": {
        "name": "John",
        "age": 30,
        "address": {
          "city": "New York",
          "country": "USA"
        }
      }
    }
  ''');

      final parser = JsonPathParser(r'$.person.*');
      final result = parser.parse(jsonValue) as JsonArray;
      expect(result.value.length, 3);
      expect(result.value[0], const JsonString('John'));
      expect(result.value[1], const JsonNumber(30));
      expect(result.value[2], isA<JsonObject>());
    });

    test('Wildcard with Array', () {
      final jsonValue = jsonValueDecode('''
    {
      "books": [
        {
          "title": "Book 1",
          "author": "Author 1"
        },
        {
          "title": "Book 2",
          "author": "Author 2"
        }
      ]
    }
  ''');

      final parser = JsonPathParser(r'$.books[*]');
      final result = parser.parse(jsonValue) as JsonArray;
      expect(result.value.length, 2);
      expect(result.value[0], isA<JsonObject>());
      expect(result.value[1], isA<JsonObject>());
    });
  });

  group(
    'Not implemented syntax',
    () {
      test('Recursive Descent with Wildcard', () {
        final jsonValue = jsonValueDecode('''
    {
      "store": {
        "books": [
          {
            "title": "Book 1",
            "author": "Author 1",
            "reviews": [
              {
                "rating": 4,
                "comment": "Great book!"
              },
              {
                "rating": 5,
                "comment": "Excellent read!"
              }
            ]
          },
          {
            "title": "Book 2",
            "author": "Author 2",
            "reviews": [
              {
                "rating": 3,
                "comment": "Average book."
              },
              {
                "rating": 4,
                "comment": "Good read."
              }
            ]
          }
        ]
      }
    }
  ''');

        final parser = JsonPathParser(r'$..reviews[*].rating');
        final result = parser.parse(jsonValue) as JsonArray;
        expect(result.value.length, 4);
        expect(result.value[0], const JsonNumber(4));
        expect(result.value[1], const JsonNumber(5));
        expect(result.value[2], const JsonNumber(3));
        expect(result.value[3], const JsonNumber(4));
      });

      test('Complex Path with Wildcards and Indexes', () {
        final jsonValue = jsonValueDecode('''
    {
      "store": {
        "name": "My Store",
        "books": [
          {
            "title": "Book 1",
            "author": "Author 1",
            "chapters": [
              {
                "title": "Chapter 1",
                "pages": 30
              },
              {
                "title": "Chapter 2",
                "pages": 25
              }
            ]
          },
          {
            "title": "Book 2",
            "author": "Author 2",
            "chapters": [
              {
                "title": "Chapter 3",
                "pages": 35
              },
              {
                "title": "Chapter 4",
                "pages": 40
              }
            ]
          }
        ]
      }
    }
  ''');

        final parser = JsonPathParser(r'$.store.books[*].chapters[1].title');
        final result = parser.parse(jsonValue) as JsonArray;
        expect(result.value.length, 2);
        expect(result.value[0].stringValue, 'Chapter 2');
        expect(result.value[1].stringValue, 'Chapter 4');
      });

      test('Bracket Notation with Quoted Field Name', () {
        final jsonValue = jsonValueDecode('''
    {
      "name": {
        "first.name": "John",
        "last.name": "Doe"
      }
    }
  ''');

        final parser = JsonPathParser(r'$.name["first.name"]');
        final result = parser.parse(jsonValue);
        expect(result.stringValue, 'John');
      });

      test('Bracket Notation with Wildcard', () {
        final jsonValue = jsonValueDecode('''
    {
      "books": [
        {
          "title": "Book 1",
          "author": "Author 1"
        },
        {
          "title": "Book 2",
          "author": "Author 2"
        }
      ]
    }
  ''');

        final parser = JsonPathParser(r'$.books[*].title');
        final result = parser.parse(jsonValue) as JsonArray;
        expect(result, isA<JsonArray>());
        expect(result.value.length, 2);
        expect(result.value[0].stringValue, 'Book 1');
        expect(result.value[1].stringValue, 'Book 2');
      });

      test('Recursive Descent with Array', () {
        final jsonValue = jsonValueDecode('''
    {
      "books": [
        {
          "title": "Book 1",
          "chapters": [
            {
              "title": "Chapter 1"
            },
            {
              "title": "Chapter 2"
            }
          ]
        },
        {
          "title": "Book 2",
          "chapters": [
            {
              "title": "Chapter 3"
            },
            {
              "title": "Chapter 4"
            }
          ]
        }
      ]
    }
  ''');

        final parser = JsonPathParser(r'$..chapters[0].title');
        final result = parser.parse(jsonValue);
        expect(result, isA<JsonString>());
        expect(result.stringValue, 'Chapter 1');
      });

      test('Recursive Descent with Object', () {
        final jsonValue = jsonValueDecode('''
    {
      "person": {
        "name": "John",
        "age": 30,
        "address": {
          "city": "New York",
          "country": "USA"
        }
      }
    }
  ''');

        final parser = JsonPathParser(r'$..city');
        final result = parser.parse(jsonValue);
        expect(result, isA<JsonString>());
        expect(result.stringValue, 'New York');
      });

      test('Union Operator', () {
        final jsonValue = jsonValueDecode('''
    {
      "person": {
        "name": "John",
        "age": 30,
        "city": "New York"
      }
    }
  ''');

        final parser = JsonPathParser(r'$.person["name","age"]');
        final result = parser.parse(jsonValue) as JsonArray;
        expect(result.value.length, 2);
        expect(result.value[0].stringValue, 'John');
        expect(result.value[1].numericValue, 30);
      });

      test('Filter Expression', () {
        final jsonValue = jsonValueDecode('''
    {
      "books": [
        {
          "title": "Book 1",
          "price": 10
        },
        {
          "title": "Book 2",
          "price": 20
        },
        {
          "title": "Book 3",
          "price": 15
        }
      ]
    }
  ''');

        final parser = JsonPathParser(r'$.books[?(@.price > 10)].title');
        final result = parser.parse(jsonValue) as JsonArray;
        expect(result.value.length, 2);
        expect(result.value[0].stringValue, 'Book 2');
        expect(result.value[1].stringValue, 'Book 3');
      });
    },
    skip: true,
  );
}
