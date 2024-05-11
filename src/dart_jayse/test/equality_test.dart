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
      "status": null
    }
  ''';

    final one = jsonValueDecode(complexJson) as JsonObject;
    final two = jsonValueDecode(complexJson) as JsonObject;

    expect(one, equals(two));
    expect(one.toString(), equals(two.toString()));
    expect(one.hashCode, equals(two.hashCode));
  });
}
