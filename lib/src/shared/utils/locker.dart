import 'dart:async';

typedef VoidCallback = void Function();

/// Allows you to make code asynchronous. Use it only with streams
/// Prefer to use the synchronized package whenever possible
class Locker {
  Future<dynamic>? _last;

  Future<VoidCallback> lock() {
    final locker = Completer.sync();
    void unLock() {
      if (identical(_last, locker.future)) {
        _last = null;
      }
      locker.complete();
    }

    final previous = _last;
    _last = locker.future;

    if (previous == null) {
      return Future.value(unLock);
    } else {
      return previous.then((_) => unLock);
    }
  }
}

extension StreamSync<T> on Stream<T> {
  Stream<T> sync(Locker locker) async* {
    final unLock = await locker.lock();
    yield* this;
    unLock();
  }
}
