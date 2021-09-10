import 'dart:async';

import 'package:kuama_flutter/kuama_flutter.dart';
import 'package:test/test.dart';

void main() {
  late Locker locker;

  setUp(() {
    locker = Locker();
  });

  group('Test Locker', () {
    test('Test synchronization', () async {
      final debugLabels = StreamController();

      String l(int workNumber, _Tag tag) => '$workNumber-$tag';

      void t(int workNumber) async {
        final unLockDone = locker.lock();
        debugLabels.add(l(workNumber, _Tag.waitLock));
        final unLock = await unLockDone;
        debugLabels.add(l(workNumber, _Tag.working));
        await Future.delayed(const Duration(milliseconds: 100));
        debugLabels.add(l(workNumber, _Tag.unLocked));
        unLock();
      }

      t(1);
      t(2);

      await expectLater(
        debugLabels.stream,
        emitsInOrder([
          l(1, _Tag.waitLock),
          l(2, _Tag.waitLock),
          l(1, _Tag.working),
          l(1, _Tag.unLocked),
          l(2, _Tag.working),
          l(2, _Tag.unLocked),
        ]),
      );
    });
  });
}

enum _Tag { waitLock, working, unLocked }
