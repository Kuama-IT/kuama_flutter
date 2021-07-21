import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/_utils/lg.dart';
import 'package:kuama_flutter/src/features/positioner/usecases/open_position_service_page.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case.dart';

Future<void> showPositionServiceDialog({
  required BuildContext context,
  required WidgetBuilder builder,
}) async {
  final theme = Theme.of(context);

  switch (theme.platform) {
    case TargetPlatform.android:
      final res = await GetIt.I<OpenPositionServicePage>().call(NoParams());
      res.fold((failure) {
        lg.e('The page to enable the position service could not be opened', failure);
      }, (wasOpened) {
        // TODO: open a dialog
        if (!wasOpened) lg.e('The page to enable the position service could not be opened');
      });
      break;
    case TargetPlatform.fuchsia:
    case TargetPlatform.iOS:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      await showDialog(
        context: context,
        builder: builder,
      );
      break;
  }
}
