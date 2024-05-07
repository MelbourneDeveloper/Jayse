import 'package:jayse/definable.dart';
import 'package:jayse/json_object.dart';

extension DefinableExtensions<T> on Definable<T> {
  T? get definedValue => switch (this) {
        Defined<T>(value: final val) => val,
        Undefined() => null,
        WrongType() => null,
      };

  Object? get value => switch (this) {
        Defined<T>(value: final val) => val,
        Undefined() => null,
        (final WrongType<T> wt) => wt.wrongTypeValue,
      };

  R? map<R>(R Function(T) f) =>
      definedValue != null ? f(definedValue as T) : null;
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
