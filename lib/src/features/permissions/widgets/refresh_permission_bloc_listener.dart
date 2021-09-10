import 'package:flutter/widgets.dart';
import 'package:kuama_flutter/src/features/permissions/bloc/permission_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Update the permission when the app returns to the foreground
class RefreshPermissionBlocListener<TPermissionBloc extends PermissionBloc>
    extends SingleChildStatefulWidget {
  final TPermissionBloc? permissionBloc;

  const RefreshPermissionBlocListener({
    Key? key,
    this.permissionBloc,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  _RefreshPermissionBlocListenerState<TPermissionBloc> createState() =>
      _RefreshPermissionBlocListenerState();
}

class _RefreshPermissionBlocListenerState<TPermissionBloc extends PermissionBloc>
    extends SingleChildState<RefreshPermissionBlocListener> with WidgetsBindingObserver {
  bool _isForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final isForeground = state == AppLifecycleState.resumed;

    if (_isForeground != isForeground) {
      _isForeground = isForeground;
      if (_isForeground) {
        (widget.permissionBloc ?? context.read<TPermissionBloc>()).load(isLazy: true);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => child!;
}

class RefreshListPermissionBlocListener extends SingleChildStatelessWidget {
  final List<PermissionBloc> permissionBlocs;

  const RefreshListPermissionBlocListener({
    Key? key,
    required this.permissionBlocs,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: permissionBlocs.map((permissionBloc) {
        return RefreshPermissionBlocListener(
          permissionBloc: permissionBloc,
        );
      }).toList(),
      child: child,
    );
  }
}
