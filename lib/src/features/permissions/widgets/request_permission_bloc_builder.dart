import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/bloc/permission_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';
import 'package:kuama_flutter/src/features/permissions/widgets/ask_allow_permission_dialog.dart';

/// Show a button to request permission when it has been denied or permanently denied
/// The button is not shown if the permission has been granted
class RequestPermissionBlocBuilder<TPermissionBloc extends PermissionBloc> extends StatelessWidget {
  final TPermissionBloc? permissionBloc;
  final Widget Function(BuildContext context, PermissionBlocState state, VoidCallback? request)
      builder;

  const RequestPermissionBlocBuilder({
    Key? key,
    this.permissionBloc,
    required this.builder,
  }) : super(key: key);

  Widget _buildRequest(BuildContext context, PermissionBlocState state, VoidCallback? request) {
    return builder(context, state, request);
  }

  @override
  Widget build(BuildContext context) {
    final permissionBloc = this.permissionBloc ?? context.read<TPermissionBloc>();

    return BlocBuilder<PermissionBloc, PermissionBlocState>(
      bloc: permissionBloc,
      builder: (context, state) {
        if (state is PermissionBlocLoaded) {
          return _buildRequest(context, state, () => permissionBloc.request(canForce: true));
        }
        if (state is PermissionBlocRequested) {
          switch (state.status) {
            case PermissionStatus.permanentlyDenied:
              return _buildRequest(
                context,
                state,
                () async {
                  permissionBloc.request(canForce: true);
                  await showDialog(
                    context: context,
                    builder: (context) => OrderAllowPermissionDialog(
                      permissionBloc: permissionBloc,
                    ),
                  );
                },
              );
            case PermissionStatus.denied:
              return _buildRequest(context, state, () => permissionBloc.request(canForce: true));
            case PermissionStatus.granted:
              return _buildRequest(context, state, null);
          }
        }
        assert(
          state is PermissionBlocRequesting || state is PermissionBlocRequestConfirm,
          'The state is: $state',
        );
        return _buildRequest(context, state, null);
      },
    );
  }
}
