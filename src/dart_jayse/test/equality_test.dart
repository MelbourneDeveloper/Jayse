import 'package:jayse/jayse.dart';
import 'package:test/test.dart';

void main() {
  test('equality', () {
    const complexJson = '''
    {
      "id": 123,
      "name": "John Doe",
      "email": "john@example.com",
      "isActive": true,
      "scores": [85, 92, 78],
      "address": {
        "street": "123 Main St",
        "city": "New York",
        "country": "USA"
      },
      "tags": ["developer", "engineer"],
      "preferences": [true, false, true],
      "mixedArray": [true, 1, "true", [1,2,3], ["a",1,2, true]],
      "status": null
    }
  ''';

    final one = jsonValueDecode(complexJson) as JsonObject;
    final two = jsonValueDecode(complexJson) as JsonObject;

    expect(one, equals(two));
    expect(one.toString(), equals(two.toString()));
    expect(one.hashCode, equals(two.hashCode));

    final mixedArray = one['mixedArray'] as JsonArray;
    final fourthElement = mixedArray[4] as JsonArray;
    expect(fourthElement.first, const JsonString('a'));
    expect(fourthElement.first.hashCode, const JsonString('a').hashCode);
    expect(fourthElement[3], const JsonBoolean(true));
    expect(fourthElement[3].hashCode, const JsonBoolean(true).hashCode);
    expect(fourthElement.length, 4);
  });
}
