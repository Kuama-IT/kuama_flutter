import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:kuama_flutter/src/shared/widgets/deferred_provider/deferred_data.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

abstract class DeferredProvider {
  DeferredProvider._();

  static DeferredData<T> of<T>(BuildContext context) {
    return Provider.of<DeferredData<T>>(context, listen: false);
  }
}

class DeferredFutureProvider<T> extends InheritedProvider<DeferredData<T>> {
  DeferredFutureProvider({
    Key? key,
    required T initialData,
    required Create<Future<T>> create,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          create: (context) => DeferredData.fromFuture(initialData, create(context)),
          dispose: null,
          lazy: lazy,
          builder: builder,
          child: child,
        );
}

class DeferredStreamProvider<T> extends InheritedProvider<DeferredData<T>> {
  DeferredStreamProvider({
    Key? key,
    required T initialData,
    required Create<Stream<T>> create,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          create: (context) => DeferredData.fromStream(initialData, create(context)),
          dispose: (context, value) => value.dispose(),
          lazy: lazy,
          builder: builder,
          child: child,
        );
}

class DeferredBuilder<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;

  const DeferredBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  _DeferredBuilderState<T> createState() => _DeferredBuilderState();
}

class _DeferredBuilderState<T> extends State<DeferredBuilder<T>> {
  late DeferredData<T> _deferredValue;

  @override
  void initState() {
    super.initState();
    _deferredValue = DeferredProvider.of<T>(context);
    _deferredValue.addListener(onChanges);
  }

  @override
  void didUpdateWidget(covariant DeferredBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentDeferredValue = DeferredProvider.of<T>(context);
    if (_deferredValue != currentDeferredValue) {
      _deferredValue.removeListener(onChanges);
      currentDeferredValue.addListener(onChanges);
    }
  }

  void onChanges() => setState(() {});

  @override
  Widget build(BuildContext context) => widget.builder(context, _deferredValue.value, null);
}

class DeferredListener<T> extends SingleChildStatefulWidget {
  final void Function(BuildContext context, T value) listener;

  const DeferredListener({
    Key? key,
    required this.listener,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  _DeferredListenerState<T> createState() => _DeferredListenerState();
}

class _DeferredListenerState<T> extends SingleChildState<DeferredListener<T>> {
  late DeferredData<T> _deferredValue;

  @override
  void initState() {
    super.initState();
    _deferredValue = DeferredProvider.of<T>(context);
    _deferredValue.addListener(onChanges);
  }

  @override
  void didUpdateWidget(covariant DeferredListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentDeferredValue = DeferredProvider.of<T>(context);
    if (_deferredValue != currentDeferredValue) {
      _deferredValue.removeListener(onChanges);
      currentDeferredValue.addListener(onChanges);
    }
  }

  void onChanges() => widget.listener(context, _deferredValue.value);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => child!;
}
