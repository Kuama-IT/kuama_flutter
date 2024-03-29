import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/bloc/permission_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/widgets/ask_allow_permission_dialog.dart';
import 'package:kuama_flutter/src/features/positioner/bloc/position_bloc.dart';
import 'package:kuama_flutter/src/features/positioner/widgets/ask_enable_position_service_dialog.dart';
import 'package:kuama_flutter/src/shared/typedefs.dart';
import 'package:provider/single_child_widget.dart';

/// It forces you to grant permission for the location and activate the geolocation service.
/// If you cancel the procedure, you will return to the previous screen.
class OrderActivePositionBlocListener extends SingleChildStatefulWidget {
  final WidgetPicker<bool?>? permissionPicker;
  final WidgetPicker<bool?>? servicePicker;

  const OrderActivePositionBlocListener({
    Key? key,
    this.permissionPicker,
    this.servicePicker,
  }) : super(key: key);

  @override
  SingleChildState<OrderActivePositionBlocListener> createState() =>
      _OrderPermissionAndServicePermissionBlocListenerState();
}

class _OrderPermissionAndServicePermissionBlocListenerState
    extends SingleChildState<OrderActivePositionBlocListener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleState(context, context.read<PositionBloc>().state);
    });
  }

  Future<void> _pick(
    BuildContext context,
    WidgetPicker<bool?>? picker,
    WidgetBuilder builder,
  ) async {
    bool? result;
    if (picker != null) {
      result = await picker(context);
    } else {
      result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: builder,
      );
    }

    if (!mounted) return;
    if (result == true) return;

    // Close the current page if any
    Navigator.of(context).maybePop();
  }

  void _handleState(BuildContext context, PositionBlocState state) async {
    if (!state.hasPermission) {
      await _pick(
        context,
        widget.permissionPicker,
        (context) => OrderAllowPermissionDialog<PermissionBloc>(
          permissionBloc: context.read<PositionBloc>().permissionBloc,
        ),
      );
      return;
    }
    if (!state.isServiceEnabled) {
      await _pick(
        context,
        widget.servicePicker,
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
