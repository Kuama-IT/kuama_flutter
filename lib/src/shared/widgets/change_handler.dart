import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// I allow to execute code whenever the value changes
class ValueChangeHandler<T> extends SingleChildStatefulWidget {
  final T? value;

  /// Call methods while the widget tree is being built
  final bool canCallImmediately;

  /// It is called whenever the value is acquired
  final void Function(BuildContext context, T value)? onAcquired;

  /// It is called whenever the old value is lost
  final void Function(BuildContext context, T value)? onLost;

  const ValueChangeHandler({
    Key? key,
    this.value,
    this.canCallImmediately = false,
    this.onAcquired,
    this.onLost,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  _HandlerState<T> createState() => _HandlerState();
}

class _HandlerState<T> extends SingleChildState<ValueChangeHandler<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value ?? context.read<T>();
    _acquire(_value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final value = _value ?? context.watch<T>();
    _updateValue(value);
  }

  @override
  void didUpdateWidget(covariant ValueChangeHandler<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = oldWidget.value ?? context.read<T>();
    _updateValue(value);
  }

  @override
  void dispose() {
    _lost(_value);
    super.dispose();
  }

  void _updateValue(T value) {
    if (_value != value) {
      _acquire(_value);
      _value = value;
      _lost(_value);
    }
  }

  void _acquire(T value) {
    _callFunction(() => widget.onAcquired?.call(context, value));
  }

  void _lost(T value) {
    _callFunction(() => widget.onLost?.call(context, value));
  }

  void _callFunction(VoidCallback function) {
    if (widget.canCallImmediately) {
      function();
    } else {
      WidgetsBinding.instance!.addPostFrameCallback((_) => function());
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => child!;
}

/// [ValueChangeHandler]
class BlocChangeHandler<TBloc extends Bloc<dynamic, TState>, TState>
    extends ValueChangeHandler<TBloc> {
  BlocChangeHandler({
    Key? key,
    TBloc? bloc,
    bool canCallImmediately = false,
    void Function(BuildContext context, TState state)? onAcquired,
    void Function(BuildContext context, TState state)? onLost,
    Widget? child,
  }) : super(
          key: key,
          value: bloc,
          canCallImmediately: canCallImmediately,
          onAcquired:
              onAcquired != null ? (context, bloc) => onAcquired(context, bloc.state) : null,
          onLost: onLost != null ? (context, bloc) => onLost(context, bloc.state) : null,
          child: child,
        );
}
