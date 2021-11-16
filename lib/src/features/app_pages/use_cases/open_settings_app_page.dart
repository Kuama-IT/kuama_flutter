import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/app_pages/repositories/app_pages_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/params.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';

/// Opens the app settings page.
///
/// Returns [true] if the app settings page could be opened, otherwise [false].
class OpenSettingsAppPage extends UseCase<NoParams, bool> {
  final AppPagesRepository launcherRepo = GetIt.I();

  @override
  Future<bool> onCall(NoParams params) async {
    return await launcherRepo.openSettings();
  }
}
