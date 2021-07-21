import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/_utils/lg.dart';
import 'package:kuama_flutter/src/features/app_pages/use_cases/open_settings_app_page.dart';
import 'package:kuama_flutter/src/features/permissions/bloc/permission_bloc.dart';
import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case.dart';

/// Confirm the permit request
class ConfirmAllowPermissionsDialog<TPermissionBloc extends PermissionBloc>
    extends StatelessWidget {
  final PermissionBloc? permissionBloc;
  final Widget? title;
  final Widget? notAllowLabel;
  final Widget? allowLabel;

  ConfirmAllowPermissionsDialog({
    Key? key,
    this.permissionBloc,
    this.title,
    this.notAllowLabel,
    this.allowLabel,
  }) : super(key: key);

  Widget _buildTitle(BuildContext context, PermissionBlocState state) {
    if (title != null) return title!;
    switch (state.permission) {
      case Permission.contacts:
        return Text('Allow to access your contacts?');
      case Permission.position:
        return Text('Allow to access your location while you are using the app?');
      case Permission.backgroundPosition:
        return Text('Allow to access your location in background?');
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionBloc = this.permissionBloc ?? context.read<TPermissionBloc>();

    return BlocConsumer<PermissionBloc, PermissionBlocState>(
      bloc: permissionBloc,
      listener: (context, state) {
        if (state is! PermissionBlocRequested) return;
        Navigator.of(context).pop(state.status.isGranted);
      },
      builder: (context, state) {
        return AlertDialog(
          title: _buildTitle(context, state),
          actions: [
            TextButton(
              onPressed: state.canRequest ? () => permissionBloc.confirmRequest(false) : null,
              child: notAllowLabel ?? Text('Not allow'),
            ),
            ElevatedButton(
              onPressed: state.canRequest ? () => permissionBloc.confirmRequest(true) : null,
              child: allowLabel ?? Text('Allow'),
            ),
          ],
        );
      },
    );
  }
}

class OrderAllowPermissionDialog<TPermissionBloc extends PermissionBloc> extends StatelessWidget {
  final PermissionBloc? permissionBloc;
  final Widget? title;
  final Widget? refreshContent;
  final Widget? cancelLabel;
  final Widget? allowLabel;
  final Widget? settingsLabel;

  const OrderAllowPermissionDialog({
    Key? key,
    this.permissionBloc,
    this.title,
    this.refreshContent,
    this.cancelLabel,
    this.settingsLabel,
    this.allowLabel,
  }) : super(key: key);

  VoidCallback? _delegateMainButtonPress(
      BuildContext context, PermissionBloc permissionBloc, PermissionBlocState state) {
    if (state.isPermanentlyDenied) {
      return () async {
        final result = await GetIt.I<OpenSettingsAppPage>().call(NoParams());
        result.fold((failure) {
          lg.e('Open Settings app page failed!', failure);
        }, (isOpened) {
          if (!isOpened) lg.e('Open Settings app page failed!');
        });
      };
    }
    if (state.canForceRequest) {
      return () => permissionBloc.request(isConfirmRequired: false, canForce: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionBloc = this.permissionBloc ?? context.read<TPermissionBloc>();

    return WillPopScope(
      onWillPop: () async => false,
      child: BlocConsumer<PermissionBloc, PermissionBlocState>(
        bloc: permissionBloc,
        listenWhen: (prev, curr) => prev.isGranted != curr.isGranted && curr.isGranted,
        listener: (context, state) => Navigator.of(context).pop(true),
        builder: (context, state) {
          return AlertDialog(
            title: title ?? Text('Position permission required'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: cancelLabel ?? Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _delegateMainButtonPress(context, permissionBloc, state),
                child: state.isPermanentlyDenied
                    ? settingsLabel ?? Text('Settings')
                    : allowLabel ?? Text('Allow'),
              ),
            ],
          );
        },
      ),
    );
  }
}
