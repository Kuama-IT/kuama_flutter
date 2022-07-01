import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/bloc/permission_bloc.dart';
import 'package:provider/single_child_widget.dart';

/// It asks for permission whenever possible and
/// allows you to build the child based on the state of the block
class RequestPermissionBlocListener<TPermissionBloc extends PermissionBloc>
    extends SingleChildStatefulWidget {
  final PermissionBloc? permissionBloc;
  final bool canForce;
  final bool isConfirmRequired;

  const RequestPermissionBlocListener({
    Key? key,
    this.permissionBloc,
    this.canForce = false,
    this.isConfirmRequired = true,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  SingleChildState<RequestPermissionBlocListener<TPermissionBloc>> createState() =>
      _PermissionBlocBuilderState();
}

class _PermissionBlocBuilderState<TPermissionBloc extends PermissionBloc>
    extends SingleChildState<RequestPermissionBlocListener<TPermissionBloc>> {
  late PermissionBloc _permissionBloc;

  @override
  void initState() {
    super.initState();
    _permissionBloc = widget.permissionBloc ?? context.read<TPermissionBloc>();
    onStateChanges(context, _permissionBloc.state);
  }

  @override
  void didUpdateWidget(covariant RequestPermissionBlocListener<TPermissionBloc> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final permissionBloc = widget.permissionBloc ?? context.read<TPermissionBloc>();
    if (_permissionBloc != permissionBloc) {
      _permissionBloc = permissionBloc;
      onStateChanges(context, _permissionBloc.state);
    }
  }

  void onStateChanges(BuildContext context, PermissionBlocState state) {
    if (state is PermissionBlocLoaded) {
      _permissionBloc.request(isConfirmRequired: widget.isConfirmRequired);
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return BlocListener<PermissionBloc, PermissionBlocState>(
      bloc: _permissionBloc,
      listener: onStateChanges,
      child: child,
    );
  }
}
