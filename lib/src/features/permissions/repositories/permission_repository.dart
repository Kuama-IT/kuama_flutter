import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';

abstract class PermissionRepository {
  const PermissionRepository._();

  /// Check the status of the permission
  /// See [PermissionStatus] for more information
  Future<PermissionStatus> check(Permission permission);

  /// Requires permission
  Future<PermissionStatus> request(Permission permission);
}
