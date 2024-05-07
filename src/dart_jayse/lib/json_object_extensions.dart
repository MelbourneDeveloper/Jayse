import 'package:jayse/definable.dart';
import 'package:jayse/json_object.dart';

/// Extension methods for [JsonObject]
extension JsonObjectExtensions on JsonObject {
  /// Returns a [Definable] of the object
  Definable<JsonObject> toDefinable() => Defined(this);
}
