import 'package:kuama_flutter/kuama_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('Test Fault', () {
    test('Test prettyMap() method work', () {
      final fault = UnhandledFailure('Error', StackTrace.current);

      expect(fault.collectDebugInfo(), isNotEmpty);
    });

    test('Test toString() method work', () {
      final fault = UnhandledFailure('Error', StackTrace.current);

      expect(fault.toString(), isNotEmpty);
    });

    test('Test prettyMap() method work with Fault instance', () {
      final fault = UnhandledFailure(HttpClientFault(), StackTrace.current);

      expect(fault.collectDebugInfo(), isNotEmpty);
    });

    test('Test toString() method work with Fault instance', () {
      final fault = UnhandledFailure(HttpClientFault(), StackTrace.current);

      expect(fault.toString(), isNotEmpty);
    });
  });
}
