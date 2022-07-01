import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/bloc/permission_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/widgets/ask_allow_permission_dialog.dart';
import 'package:kuama_flutter/src/shared/widgets/change_handler.dart';
import 'package:provider/single_child_widget.dart';

typedef PermissionRequest = Future<bool?> Function(
    BuildContext context, PermissionBlocRequestConfirm state);

/// Show the permission request dialog based on the bloc permission
class AskAllowPermissionBlocListener<TPermissionBloc extends PermissionBloc>
    extends SingleChildStatelessWidget {
  final TPermissionBloc? permissionBloc;
  final PermissionRequest? permissionRequester;

  const AskAllowPermissionBlocListener({
    Key? key,
    this.permissionBloc,
    this.permissionRequester,
    Widget? child,
  }) : super(key: key, child: child);

  Future<bool?> requestConfirm(BuildContext context, PermissionBloc permissionBloc,
      PermissionBlocRequestConfirm state) async {
    if (permissionRequester != null) {
      return await permissionRequester!(context, state);
    }
    return await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmAllowPermissionsDialog(permissionBloc: permissionBloc),
    );
  }

  Future<void> onState(BuildContext context, PermissionBloc permissionBloc,
      PermissionBlocRequestConfirm state) async {
    final result = await requestConfirm(context, permissionBloc, state);
    permissionBloc.confirmRequest(result ?? false);
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final permissionBloc = this.permissionBloc ?? context.read<TPermissionBloc>();

    return ValueChangeHandler<TPermissionBloc>(
      value: permissionBloc,
      onAcquired: (context, permissionBloc) {
        final state = permissionBloc.state;
        if (state is! PermissionBlocRequestConfirm) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onState(context, permissionBloc, state);
        });
      },
      child: BlocListener<TPermissionBloc, PermissionBlocState>(
        bloc: permissionBloc,
        listener: (context, state) {
          if (state is! PermissionBlocRequestConfirm) return;
          onState(context, permissionBloc, state);
        },
        child: child,
      ),
    );
  }
}
