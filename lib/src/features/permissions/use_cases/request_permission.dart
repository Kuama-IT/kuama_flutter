import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';
import 'package:kuama_flutter/src/features/permissions/repositories/permission_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';

/// Requires permission
class RequestPermission extends UseCase<Permission, PermissionStatus> {
  final PermissionRepository permissionsRepo = GetIt.I();

  @override
  Future<PermissionStatus> onCall(Permission params) async {
    final permission = params;

    return await permissionsRepo.request(permission);
  }
}
