import 'dart:convert';

import 'package:jayse/definable.dart';

class JsonObject {
  JsonObject(this._value);

  JsonObject.fromJson(String json)
      : _value = jsonDecode(json) as Map<String, dynamic>;

  final Map<String, dynamic> _value;

  // ignore: avoid_annotating_with_dynamic
  JsonObject update(String key, dynamic value) {
    final clonedMap = Map<String, dynamic>.from(_value)..remove(key);
    clonedMap[key] = value;
    final entries = clonedMap.entries.toList();
    return JsonObject(Map.fromEntries(entries));
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(_value);

  Definable<T> getValue<T>(String field) => switch (_value[field]) {
        (final T value) => Defined(value),
        //Case the field is a list of objects and we need a list of JsonObjects
        //Note: this case won't occur when deserializing from JSON
        (final List<Map<String, dynamic>> list) when T == (List<JsonObject>) =>
          //Convert to a list of JsonObjects and cast to enforce it
          Defined(list.map(JsonObject.new).toList() as T),
        (final List<dynamic> list)
            when T == (List<JsonObject>) &&
                list.every((element) => element is Map<String, dynamic>) =>
          Defined(
            //We need to coerce with as in the case. TODO: use better pattern
            //matching here so we don't need as
            list.map((map) => JsonObject(map as Map<String, dynamic>)).toList()
                as T,
          ),
        (final Object value) => WrongType(wrongTypeValue: value),
        _ => const Undefined(),
      };
}
