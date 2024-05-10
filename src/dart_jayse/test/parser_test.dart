import 'package:jayse/jayse.dart';
import 'package:jayse/parser.dart';
import 'package:test/test.dart';

void main() {
  setUp(
    () => log = (step, currentPath, value) =>
        // ignore: avoid_print
        print('Step: $step. Path: $currentPath Value: $value'),
  );

  group('Implemented Syntax', () {
    test('Basic Property Access', () {
      final jsonValue = jsonValueDecode('''
    {
      "name": "Alice",
      "age": 30
    }
    ''');

      final result = parseJsonPath(r'$.name', jsonValue);

      expect(result.stringValue, 'Alice');
    });

    test('Array Index Access', () {
      final result = parseJsonPath(
        r'$.users[1]',
        jsonValueDecode('''{"users": ["Alice", "Bob", "Charlie"]}'''),
      );

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

      final result = parseJsonPath(r'$.organization.address.city', jsonValue);

      expect(result.stringValue, 'San Francisco');
    });

    test('Access Non-Existent Property', () {
      final jsonValue = jsonValueDecode('''
    {
      "name": "Alice",
      "age": 30
    }
    ''');

      final result = parseJsonPath(r'$.salary', jsonValue);

      expect(result, const Undefined());
    });

    test('Root Property Access', () {
      final jsonValue = jsonValueDecode('''
    {
      "name": "Bob"
    }
    ''');

      final result = parseJsonPath(r'$', jsonValue);

      expect(result['name'].stringValue, 'Bob');
    });

    test('Path Test Basic', () async {
      final jsonValue = jsonValueDecode('''{"author": "bob"}''');
      expect(parseJsonPath(r'$..author', jsonValue), const JsonString('bob'));
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

      final result = parseJsonPath(r'$..book[2].author', jsonValue);

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

      final result = parseJsonPath(r'$.person.*', jsonValue) as JsonArray;
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

      final result = parseJsonPath(r'$.books[*]', jsonValue) as JsonArray;
      expect(result.value.length, 2);
      expect(result.value[0], isA<JsonObject>());
      expect(result.value[1], isA<JsonObject>());
    });

    test('Chain of Array Indexes', () {
      final jsonValue = jsonValueDecode('''
    {
      "store": {
        "book": [
          { "category": "reference",
            "author": "Nigel Rees",
            "title": "Sayings of the Century",
            "price": 8.95
          },
          { "category": "fiction",
            "author": "Evelyn Waugh",
            "title": "Sword of Honour",
            "price": 12.99
          },
          { "category": "fiction",
            "author": "Herman Melville",
            "title": "Moby Dick",
            "isbn": "0-553-21311-3",
            "price": 8.99
          }
        ]
      }
    }
    ''');

      final result = parseJsonPath(r'$.store.book[0].title', jsonValue);
      expect(result.stringValue, 'Sayings of the Century');
    });

    test('Non-Existent Deep Property', () {
      final jsonValue = jsonValueDecode('''
    {
      "store": {
        "book": [
          { "category": "reference",
            "author": "Nigel Rees",
            "title": "Sayings of the Century",
            "price": 8.95
          }
        ]
      }
    }
    ''');

      final result = parseJsonPath(r'$.store.bicycle.color', jsonValue);
      expect(result, const Undefined());
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

      final result =
          parseJsonPath(r'$.store.books[*].chapters[1].title', jsonValue)
              as JsonArray;
      expect(result.value.length, 2);
      expect(result.value[0].stringValue, 'Chapter 2');
      expect(result.value[1].stringValue, 'Chapter 4');
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

      final result = parseJsonPath(r'$.books[*].title', jsonValue) as JsonArray;
      expect(result, isA<JsonArray>());
      expect(result.value.length, 2);
      expect(result.value[0].stringValue, 'Book 1');
      expect(result.value[1].stringValue, 'Book 2');
    });
  });

  group('Path Extensions', () {
    test('JSON Path Extensions', () {
      final jsonObject = jsonValueDecode('''
      {
        "name": "John Doe",
        "age": 30,
        "isStudent": false,
        "score": 85.5,
        "graduation": "2022-06-30T10:00:00Z",
        "address": {
          "street": "123 Main St",
          "city": "New York",
          "country": "USA"
        },
        "phoneNumbers": [
          {
            "type": "home",
            "number": "212-555-1234"
          },
          {
            "type": "work",
            "number": "646-555-5678"
          }
        ],
        "courses": [
          "Math",
          "Science",
          "English"
        ],
        "grades": [
          90,
          85,
          92
        ],
        "gpa": 3.8,
        "graduated": true
      }
    ''') as JsonObject;

      // Test fromPath
      expect(jsonObject.fromPath(r'$.name'), const JsonString('John Doe'));
      expect(jsonObject.fromPath(r'$.age'), const JsonNumber(30));
      expect(jsonObject.fromPath(r'$.isStudent'), const JsonBoolean(false));
      expect(jsonObject.fromPath(r'$.score'), const JsonNumber(85.5));
      expect(
        jsonObject.fromPath(r'$.graduation'),
        const JsonString('2022-06-30T10:00:00Z'),
      );
      expect(
        jsonObject.fromPath(r'$.address.city'),
        const JsonString('New York'),
      );
      expect(
        jsonObject.fromPath(r'$.phoneNumbers[0].number'),
        const JsonString('212-555-1234'),
      );
      expect(jsonObject.fromPath(r'$.courses[1]'), const JsonString('Science'));
      expect(jsonObject.fromPath(r'$.grades[2]'), const JsonNumber(92));
      expect(jsonObject.fromPath(r'$.gpa'), const JsonNumber(3.8));
      expect(jsonObject.fromPath(r'$.graduated'), const JsonBoolean(true));

      // Test stringFromPath
      expect(jsonObject.stringFromPath(r'$.name'), 'John Doe');
      expect(jsonObject.stringFromPath(r'$.address.street'), '123 Main St');
      expect(jsonObject.stringFromPath(r'$.phoneNumbers[1].type'), 'work');
      expect(jsonObject.stringFromPath(r'$.courses[0]'), 'Math');

      // Test integerFromPath
      expect(jsonObject.integerFromPath(r'$.age'), 30);
      expect(jsonObject.integerFromPath(r'$.grades[0]'), 90);

      // Test doubleFromPath
      expect(jsonObject.doubleFromPath(r'$.score'), 85.5);
      expect(jsonObject.doubleFromPath(r'$.gpa'), 3.8);

      // Test boolFromPath
      expect(jsonObject.boolFromPath(r'$.isStudent'), false);
      expect(jsonObject.boolFromPath(r'$.graduated'), true);

      // Test dateFromPath
      expect(
        jsonObject.dateFromPath(r'$.graduation'),
        DateTime.utc(2022, 6, 30, 10),
      );

      // Additional tests
      expect(jsonObject.fromPath(r'$.address'), isA<JsonObject>());
      expect(jsonObject.fromPath(r'$.phoneNumbers'), isA<JsonArray>());
      expect(
        jsonObject.fromPath(r'$.phoneNumbers[*].number'),
        isA<JsonArray>(),
      );
      expect(
        jsonObject
            .fromPath(r'$.phoneNumbers[*].number')
            .arrayValue
            ?.map((e) => e.stringValue),
        equals(['212-555-1234', '646-555-5678']),
      );

      //TODO: not implemented
      // expect(jsonObject.fromPath(r'$.courses[0,2]'), isA<JsonArray>());
      // expect(
      //   jsonObject
      //       .fromPath(r'$.courses[0,2]')
      //       .arrayValue
      //       ?.map((e) => e.stringValue),
      //   equals(['Math', 'English']),
      // );
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

        final result =
            parseJsonPath(r'$..reviews[*].rating', jsonValue) as JsonArray;
        expect(result.value.length, 4);
        expect(result.value[0], const JsonNumber(4));
        expect(result.value[1], const JsonNumber(5));
        expect(result.value[2], const JsonNumber(3));
        expect(result.value[3], const JsonNumber(4));
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

        final result = parseJsonPath(r'$.name["first.name"]', jsonValue);
        expect(result.stringValue, 'John');
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

        final result = parseJsonPath(r'$..chapters[0].title', jsonValue);
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

        final result = parseJsonPath(r'$..city', jsonValue);
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

        final result =
            parseJsonPath(r'$.person["name","age"]', jsonValue) as JsonArray;
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

        final result =
            parseJsonPath(r'$.books[?(@.price > 10)].title', jsonValue)
                as JsonArray;
        expect(result.value.length, 2);
        expect(result.value[0].stringValue, 'Book 2');
        expect(result.value[1].stringValue, 'Book 3');
      });

      test('Recursive Descent', () {
        final jsonValue = jsonValueDecode('''
    {
      "store": {
        "book": [
          { "category": "reference",
            "author": "Nigel Rees",
            "title": "Sayings of the Century",
            "price": 8.95
          },
          { "category": "fiction",
            "author": "Evelyn Waugh",
            "title": "Sword of Honour",
            "price": 12.99
          }
        ],
        "bicycle": {
          "color": "red",
          "price": 19.95
        }
      }
    }
    ''');

        final result = parseJsonPath(r'$.store..price', jsonValue) as JsonArray;
        expect(result.value.length, 3);
        expect(result.value, containsAll([8.95, 12.99, 19.95]));
      });

      test('Filter Expression with Predicate', () {
        final jsonValue = jsonValueDecode('''
    {
      "store": {
        "book": [
          { "category": "reference",
            "author": "Nigel Rees",
            "title": "Sayings of the Century",
            "price": 8.95
          },
          { "category": "fiction",
            "author": "Evelyn Waugh",
            "title": "Sword of Honour",
            "price": 12.99
          },
          { "category": "fiction",
            "author": "Herman Melville",
            "title": "Moby Dick",
            "isbn": "0-553-21311-3",
            "price": 8.99
          }
        ]
      }
    }
    ''');

        final result =
            parseJsonPath(r'$.store.book[?(@.price < 10)]', jsonValue)
                as JsonArray;
        expect(result.value.length, 2);
        expect(result.value[0]['title'].stringValue, 'Sayings of the Century');
        expect(result.value[1]['title'].stringValue, 'Moby Dick');
      });
    },
    skip: true,
  );
}
