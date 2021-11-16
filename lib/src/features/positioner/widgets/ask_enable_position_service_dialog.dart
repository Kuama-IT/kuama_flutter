import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/_utils/lg.dart';
import 'package:kuama_flutter/src/features/positioner/bloc/position_bloc.dart';
import 'package:kuama_flutter/src/features/positioner/usecases/open_position_service_page.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/params.dart';
import 'package:kuama_flutter/src/shared/widgets/change_handler.dart';
import 'package:kuama_flutter/src/shared/widgets/dialogs/app_settings_dialog.dart';

class AskEnablePositionServiceDialog extends StatelessWidget {
  const AskEnablePositionServiceDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PositionBloc, PositionBlocState>(
      listenWhen: (prev, curr) =>
          prev.isServiceEnabled != curr.isServiceEnabled && curr.isServiceEnabled,
      // Auto closing of the dialog when the service has been enabled
      listener: (context, state) => Navigator.of(context).pop(true),
      child: AskOpenSettingsPageDialog(
        openSettings: GetIt.I<OpenPositionServicePage>(),
        title: const Text('Please turn on the device position'),
      ),
    );
  }
}

class OrderEnablePositionServiceDialog extends StatelessWidget {
  final Widget? title;
  final Widget? cancelLabel;
  final Widget? settingsLabel;

  const OrderEnablePositionServiceDialog({
    Key? key,
    this.title,
    this.cancelLabel,
    this.settingsLabel,
  }) : super(key: key);

  // Auto closing of the dialog when the service has been enabled
  void _onState(BuildContext context, PositionBlocState state) {
    if (state.isServiceEnabled) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocChangeHandler<PositionBloc, PositionBlocState>(
      onAcquired: _onState,
      child: BlocListener<PositionBloc, PositionBlocState>(
        listenWhen: (prev, curr) => prev.isServiceEnabled != curr.isServiceEnabled,
        listener: _onState,
        child: WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: title ?? const Text('Please turn on the device position'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: cancelLabel ?? const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final isOpened = await GetIt.I<OpenPositionServicePage>().call(NoParams());
                  if (!isOpened) lg.e('Open Location Settings page failed!');
                },
                child: settingsLabel ?? const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
