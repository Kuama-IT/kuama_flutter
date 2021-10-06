import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/positioner/repositories/position_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failures/dart_failures.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/params.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';

/// Open the position service page to enable it
class OpenPositionServicePage extends UseCase<NoParams, bool> {
  final PositionRepository locatorRepo = GetIt.I();

  @override
  Future<Either<Failure, bool>> tryCall(NoParams params) {
    return locatorRepo.openServicePage().toRight();
  }
}
