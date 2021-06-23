import 'package:test/test.dart';
import 'package:kuama_flutter/kuama_flutter.dart';

void main() {
  group('Test Fault', () {
    test('Test prettyMap() method work', () {
      final fault = HttpClientFault();

      expect(fault.toPrettyMap(), isNotEmpty);
    });

    test('Test toString() method work', () {
      final fault = HttpClientFault();

      expect(fault.toString(), isNotEmpty);
    });

    test('Test prettyMap() method work with generic error', () {
      final fault = HttpClientFault(error: ErrorAndStackTrace('Error', StackTrace.current));

      expect(fault.toPrettyMap(), isNotEmpty);
    });

    test('Test toString() method work with generic error', () {
      final fault = HttpClientFault(error: ErrorAndStackTrace('Error', StackTrace.current));

      expect(fault.toString(), isNotEmpty);
    });
  });
}
