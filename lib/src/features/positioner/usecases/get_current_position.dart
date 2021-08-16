import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/positioner/repositories/position_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failure.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case.dart';
import 'package:pure_extensions/pure_extensions.dart';

/// Request the current position of the user
class GetCurrentPosition extends UseCase<NoParams, GeoPoint> {
  final PositionRepository locatorRepo = GetIt.I();

  @override
  Future<Either<Failure, GeoPoint>> tryCall(NoParams params) {
    return locatorRepo.currentPosition.toRight();
  }
}
