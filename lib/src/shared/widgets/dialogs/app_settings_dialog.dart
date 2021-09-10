import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/_utils/lg.dart';
import 'package:kuama_flutter/src/features/app_pages/use_cases/open_settings_app_page.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case.dart';

class AskOpenAppSettingsPageDialog extends StatelessWidget {
  final Widget? title;
  final Widget? cancelLabel;
  final Widget? settingsLabel;

  const AskOpenAppSettingsPageDialog({
    Key? key,
    this.title,
    this.cancelLabel,
    this.settingsLabel,
  }) : super(key: key);

  void openSettingsPage() async {
    final res = await GetIt.I<OpenSettingsAppPage>().call(NoParams());
    res.fold((failure) {
      lg.e('The app settings page could not be opened', failure);
    }, (wasOpened) {
      if (!wasOpened) lg.e('The app settings page could not be opened');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title ?? const Text('Open app settings'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: cancelLabel ?? const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: openSettingsPage,
          child: settingsLabel ?? const Text('Settings'),
        ),
      ],
    );
  }
}
