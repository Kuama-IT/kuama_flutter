import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/_utils/lg.dart';
import 'package:kuama_flutter/src/features/positioner/usecases/open_position_service_page.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/params.dart';

Future<void> showPositionServiceDialog({
  required BuildContext context,
  required WidgetBuilder builder,
}) async {
  final theme = Theme.of(context);

  switch (theme.platform) {
    case TargetPlatform.android:
      final wasOpened = await GetIt.I<OpenPositionServicePage>().call(NoParams());
      if (!wasOpened) lg.e('The page to enable the position service could not be opened');
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
