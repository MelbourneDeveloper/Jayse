import 'package:jayse/definable_extensions.dart';

sealed class Definable<T> {
  const Definable();

  bool equals(T other) => this is Defined && value == other;
}

final class Undefined<T> extends Definable<T> {
  const Undefined();

  @override
  //Note: We don't specify a type argument here because they may not
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
