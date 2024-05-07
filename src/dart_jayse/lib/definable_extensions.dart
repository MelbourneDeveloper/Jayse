import 'package:jayse/definable.dart';
import 'package:jayse/json_object.dart';

/// Extension methods for [Definable]
extension DefinableExtensions<T> on Definable<T> {

  /// Returns the defined value if it is defined and has the correct type, 
  /// otherwise returns null
  T? get definedValue => switch (this) {
        Defined<T>(value: final val) => val,
        Undefined() => null,
        WrongType() => null,
      };

  /// Returns value if it is defined, but without strong typing, and
  /// without any distinction between null and undefined
  Object? get value => switch (this) {
        Defined<T>(value: final val) => val,
        Undefined() => null,
        (final WrongType<T> wt) => wt.wrongTypeValue,
      };

  /// Allows you to map the defined value to a new value or returns null
  R? map<R>(R Function(T) f) =>
      definedValue != null ? f(definedValue as T) : null;
}

/// Extension methods for [Definable]s that contain [JsonObject]s
extension ListExtensions on Definable<List<JsonObject>> {

  /// Returns the defined value if it is defined and has the correct type,
  Definable<JsonObject> operator [](int index) =>
      switch (definedValue?[index]) {
        (final JsonObject json) => Defined(json),
        _ => const Undefined(),
      };

  /// Returns the first element of the defined value if it is defined and has
  Definable<JsonObject> get first => switch (this) {
        (final Defined<List<JsonObject>> defined) =>
          Defined(defined.value?.first),
        _ => const Undefined(),
      };
}
