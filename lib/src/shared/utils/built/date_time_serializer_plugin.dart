import 'package:built_value/serializer.dart';
import 'package:pure_extensions/pure_extensions.dart';

/// Converts local [DateTime] to utc [DateTime]
// copyWith method ignores date is utc
class DateTimeSerializerPlugin extends SerializerPlugin {
  final bool canUseMicroseconds;

  DateTimeSerializerPlugin({this.canUseMicroseconds = true});

  @override
  Object? beforeSerialize(Object? object, FullType specifiedType) {
    if (object is DateTime) {
      if (!canUseMicroseconds) {
        object = object.copyWith(microsecond: 0);
      }
      return object.toUtc();
    }
    return object;
  }

  @override
  Object? afterSerialize(Object? object, FullType specifiedType) => object;

  @override
  Object? beforeDeserialize(Object? object, FullType specifiedType) => object;

  @override
  Object? afterDeserialize(Object? object, FullType specifiedType) {
    if (object is DateTime) {
      object = object.toLocal();
      if (!canUseMicroseconds) {
        return object.copyWith(microsecond: 0);
      }
      return object;
    }
    return object;
  }
}
