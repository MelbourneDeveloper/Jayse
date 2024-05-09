import 'package:jayse/jayse.dart';
import 'package:jayse/parser.dart';

import 'package:test/test.dart';

void main() {
  test('Path Test', () async {
    const jsonString = '''
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
  ''';

    // ignore: unused_local_variable
    final jsonValue = jsonValueDecode(jsonString);
    // ignore: unused_local_variable
    const jsonPath = r'$..book[2].author';

    // ignore: unused_local_variable
    final parser = JsonPathParser(jsonPath);
    final result = parser.parse(jsonValue);

    expect(result.stringValue, 'Mark Johnson');
  });
}
