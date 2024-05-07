import 'package:jayse/definable_extensions.dart';
import 'package:jayse/json_object.dart';

/// A class that represents a value that may or may not be defined in a
/// [JsonObject]
sealed class Definable<T> {
  const Definable();

  /// Returns true if this value is defined and is equal to [other]
  bool equals(T other) => this is Defined && value == other;
}

/// A class that represents a value that is not defined in a [JsonObject]
final class Undefined<T> extends Definable<T> {
  /// Creates an instance of [Undefined]
  const Undefined();

  @override
  //Note: We don't specify a type argument here because they may not
  //match. But, regardless of type, undefined is undefined

  bool operator ==(Object other) => other is Undefined;

  //TODO: is there a different option here?
  @override
  int get hashCode => 'Undefined'.hashCode;
}

/// A class that represents a value that is defined in a [JsonObject] but is of
/// the wrong type
final class WrongType<T> extends Definable<T> {
  /// Creates an instance of [WrongType]
  WrongType({required this.wrongTypeValue});

  /// The value that is of the wrong type
  final Object wrongTypeValue;
}

/// A class that represents a value that is defined in a [JsonObject] and is
/// of the correct type
final class Defined<T> extends Definable<T> {
  /// Creates an instance of [Defined]
  Defined(this.value);

  /// The value of this instance that may be null
  final T? value;

  @override
  bool operator ==(Object other) => other is Defined<T> && other.value == value;

  @override
  int get hashCode => value?.hashCode ?? 0.hashCode;
}
