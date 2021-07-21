import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';
import 'package:kuama_flutter/src/features/permissions/repositories/permission_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failure.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case.dart';

/// Check the status of the permission
/// See [PermissionStatus] for more information
class CheckPermission extends UseCase<Permission, PermissionStatus> {
  final PermissionRepository permissionsRepo = GetIt.I();

  @override
  Future<Either<Failure, PermissionStatus>> tryCall(Permission permission) async {
    return permissionsRepo.check(permission).toRight();
  }
}
