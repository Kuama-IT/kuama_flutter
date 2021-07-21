import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class DeferredData<T> extends ValueNotifier<T> {
  bool _isDisposed = false;

  DeferredData(T value) : super(value);

  factory DeferredData.fromFuture(T initialValue, Future<T> future) = _DeferredFuture;

  factory DeferredData.fromStream(T initialValue, Stream<T> stream) = _DeferredStream;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

class _DeferredFuture<T> extends DeferredData<T> {
  _DeferredFuture(T initialValue, Future<T> future) : super(initialValue) {
    future.then((value) {
      if (_isDisposed) return;
      this.value = value;
    });
  }
}

class _DeferredStream<T> extends DeferredData<T> {
  late StreamSubscription _sub;

  _DeferredStream(T initialValue, Stream<T> stream) : super(initialValue) {
    _sub = stream.listen((value) {
      if (_isDisposed) return;
      this.value = value;
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
