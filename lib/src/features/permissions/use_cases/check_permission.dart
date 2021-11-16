import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';
import 'package:kuama_flutter/src/features/permissions/repositories/permission_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';

/// Check the status of the permission
/// See [PermissionStatus] for more information
class CheckPermission extends UseCase<Permission, PermissionStatus> {
  final PermissionRepository permissionsRepo = GetIt.I();

  @override
  Future<PermissionStatus> onCall(Permission params) async {
    final permission = params;

    return await permissionsRepo.check(permission);
  }
}
