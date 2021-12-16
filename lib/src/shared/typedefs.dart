import 'package:flutter/widgets.dart';

typedef ButtonWidgetBuilder = Widget Function(BuildContext context, VoidCallback? onTap);

typedef ButtonBlocWidgetBuilder<TState> = Widget Function(
    BuildContext context, TState state, VoidCallback? onTap);

typedef ProgressBuilder = Widget Function(BuildContext context, double? progress);

typedef WidgetPicker<T> = Future<T> Function(BuildContext context);

class Param<T> {
  final T value;

  const Param(this.value);
}
