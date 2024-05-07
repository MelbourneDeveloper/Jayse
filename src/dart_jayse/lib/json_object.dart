import 'dart:convert';

sealed class Definable<T> {
  const Definable();

  bool equals(T other) => this is Defined && value == other;

  R? map<R>(R Function(T) f) =>
      definedValue != null ? f(definedValue as T) : null;
}

final class Undefined<T> extends Definable<T> {
  const Undefined();

  @override
  //Note: We don't specify a t-ype argument here because they may not
  //match. But, regardless of type, undefined is undefined

  bool operator ==(Object other) => other is Undefined;

  //TODO: is there a different option here?
  @override
  int get hashCode => 'Undefined'.hashCode;
}

final class WrongType<T> extends Definable<T> {
  WrongType({required this.wrongTypeValue});

  final Object wrongTypeValue;
}

final class Defined<T> extends Definable<T> {
  Defined(this.value);

  final T? value;

  @override
  bool operator ==(Object other) => other is Defined<T> && other.value == value;

  @override
  int get hashCode => value?.hashCode ?? 0.hashCode;
}

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
}

extension DefinableExtensions<T> on Definable<T> {
  T? get definedValue => switch (this) {
        Defined<T>(value: final val) => val,
        Undefined() => null,
        WrongType() => null,
      };

  dynamic get value => switch (this) {
        Defined<T>(value: final val) => val,
        Undefined() => null,
        (final WrongType<T> wt) => wt.wrongTypeValue,
      };
}

extension JsonExtensions on JsonObject {
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

  Definable<JsonObject> toDefinable() => Defined(this);
}

extension ListExtensions on Definable<List<JsonObject>> {
  Definable<JsonObject> operator [](int index) =>
      switch (definedValue?[index]) {
        (final JsonObject json) => Defined(json),
        _ => const Undefined(),
      };

  Definable<JsonObject> get first => switch (this) {
        (final Defined<List<JsonObject>> defined) =>
          Defined(defined.value?.first),
        _ => const Undefined(),
      };
}
