import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/bloc/permission_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/widgets/request_permission_bloc_builder.dart';
import 'package:kuama_flutter/src/features/positioner/bloc/positioner_bloc.dart';
import 'package:kuama_flutter/src/features/positioner/widgets/_utils.dart';
import 'package:kuama_flutter/src/features/positioner/widgets/ask_enable_position_service_dialog.dart';
import 'package:kuama_flutter/src/shared/typedefs.dart';
import 'package:pure_extensions/pure_extensions.dart';

/// Constructs the widget only when the current position can be retrieved
class LocalizePositionBlocBuilder extends StatelessWidget {
  /// Defines whether the builder with realtime location only should be called
  final bool isRealTimeRequired;
  final Future<void> Function(BuildContext context, PermissionBlocRequestConfirm state)?
      serviceRequester;
  final ButtonBlocWidgetBuilder<PermissionBlocState> permissionBuilder;
  final ButtonBlocWidgetBuilder<PositionerBlocState> serviceBuilder;

  /// The [position] is null when the bloc is processing it
  final Widget Function(BuildContext context, GeoPoint? position) builder;

  const LocalizePositionBlocBuilder({
    Key? key,
    required this.isRealTimeRequired,
    this.serviceRequester,
    required this.permissionBuilder,
    required this.serviceBuilder,
    required this.builder,
  }) : super(key: key);

  Future<void> _requestService(BuildContext context, PositionerBlocState state) async {
    await showPositionServiceDialog(
      context: context,
      builder: (context) => AskEnablePositionServiceDialog(),
    );
  }

  Widget _build(BuildContext context, PositionerBlocState state) {
    if (!isRealTimeRequired) {
      final position = state.lastPosition;
      if (position != null) {
        return builder(context, position);
      }
    }
    if (state is PositionerBlocLocated) {
      if (state.isRealTime) {
        return builder(context, state.currentPosition);
      }
    }

    return builder(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return RequestPermissionBlocBuilder<PositionPermissionBloc>(
      builder: (context, state, request) {
        if (!state.isGranted) {
          return permissionBuilder(context, state, request);
        }

        return BlocBuilder<PositionerBloc, PositionerBlocState>(
          builder: (context, state) {
            if (state is PositionerBlocIdle) {
              return serviceBuilder(context, state, () => _requestService(context, state));
            }
            return _build(context, state);
          },
        );
      },
    );
  }
}
