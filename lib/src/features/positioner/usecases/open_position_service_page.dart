import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/positioner/repositories/locator_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failure.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case.dart';

/// Open the position service page to enable it
class OpenPositionServicePage extends UseCase<NoParams, bool> {
  final LocatorRepository locatorRepo = GetIt.I();

  @override
  Stream<Either<Failure, bool>> tryCall(NoParams params) {
    return locatorRepo.openServicePage().toRight();
  }
}
