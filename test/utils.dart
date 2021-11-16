import 'package:mocktail/mocktail.dart';

final fallbackValues = FallbackValues._();

class FallbackValues {
  FallbackValues._();

  void register(Object value) {
    registerFallbackValue(value);
  }

  void registerEnum(List<Enum> values) {
    for (final value in values) {
      registerFallbackValue(value);
    }
  }
}
