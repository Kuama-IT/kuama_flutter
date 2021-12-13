import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/bloc/permission_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/widgets/ask_allow_permission_dialog.dart';
import 'package:kuama_flutter/src/features/positioner/bloc/position_bloc.dart';
import 'package:kuama_flutter/src/features/positioner/widgets/ask_enable_position_service_dialog.dart';
import 'package:provider/single_child_widget.dart';

/// It forces you to grant permission for the location and activate the geolocation service.
/// If you cancel the procedure, you will return to the previous screen.
class OrderActivePositionBlocListener extends SingleChildStatefulWidget {
  const OrderActivePositionBlocListener({Key? key}) : super(key: key);

  @override
  _OrderPermissionAndServicePermissionBlocListenerState createState() =>
      _OrderPermissionAndServicePermissionBlocListenerState();
}

class _OrderPermissionAndServicePermissionBlocListenerState
    extends SingleChildState<OrderActivePositionBlocListener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _handleState(context, context.read<PositionBloc>().state);
    });
  }

  Future<void> _handleDialog(
      BuildContext context, PositionBlocState state, WidgetBuilder builder) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: builder,
    );
    if (result != true) Navigator.of(context).pop();
  }

  void _handleState(BuildContext context, PositionBlocState state) async {
    if (!state.hasPermission) {
      await _handleDialog(
        context,
        state,
        (context) => OrderAllowPermissionDialog<PermissionBloc>(
          permissionBloc: context.read<PositionBloc>().permissionBloc,
        ),
      );
      return;
    }
    if (!state.isServiceEnabled) {
      await _handleDialog(
        context,
        state,
        (context) => const OrderEnablePositionServiceDialog(),
      );
      return;
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return BlocListener<PositionBloc, PositionBlocState>(
      listener: _handleState,
      child: child,
    );
  }
}
