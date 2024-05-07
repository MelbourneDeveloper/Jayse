import 'package:jayse/definable.dart';
import 'package:jayse/json_object.dart';

extension JsonObjectExtensions on JsonObject {
 

  Definable<JsonObject> toDefinable() => Defined(this);
}
