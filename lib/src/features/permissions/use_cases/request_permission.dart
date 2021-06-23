import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';
import 'package:kuama_flutter/src/features/permissions/repositories/permission_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failure.dart';
import 'package:kuama_flutter/src/shared/utils/locker.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case.dart';

/// Requires permission
class RequestPermission extends UseCase<Permission, PermissionStatus> {
  final PermissionRepository permissionsRepo = GetIt.I();

  static final _locker = Locker();

  @override
  Stream<Either<Failure, PermissionStatus>> tryCall(Permission permission) async* {
    yield* permissionsRepo.request(permission).sync(_locker).toRight<Failure>();
  }
}
