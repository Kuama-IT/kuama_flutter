import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/app_pages/repositories/app_pages_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failure.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case.dart';

/// Opens the app settings page.
///
/// Returns [true] if the app settings page could be opened, otherwise [false].
class OpenSettingsAppPage extends UseCase<NoParams, bool> {
  final AppPagesRepository launcherRepo = GetIt.I();

  @override
  Stream<Either<Failure, bool>> tryCall(NoParams _) async* {
    yield* launcherRepo.openSettings().toRight();
  }
}
