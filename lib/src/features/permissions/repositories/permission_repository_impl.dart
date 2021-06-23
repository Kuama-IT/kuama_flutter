import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';
import 'package:kuama_flutter/src/features/permissions/repositories/permission_repository.dart';
import 'package:kuama_flutter/src/shared/library_exports.dart';
import 'package:kuama_flutter/src/_utils/lg.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart'
    as ph;

/// [PermissionRepository]
class PermissionRepositoryImpl implements PermissionRepository {
  final ph.PermissionHandlerPlatform permissionHandler = GetIt.I();

  /// [PermissionRepository.check]
  @override
  Stream<PermissionStatus> check(Permission permission) async* {
    final currentPermission = permission.toPermissionHandler();
    final status = await permissionHandler.checkPermissionStatus(currentPermission);
    lg.fine('PermissionRepositoryImpl.check | $permission: $status');
    yield status.toStatus();
  }

  /// [PermissionRepository.request]
  @override
  Stream<PermissionStatus> request(Permission permission) async* {
    final currentPermission = permission.toPermissionHandler();
    final status = await permissionHandler.requestPermissions([currentPermission]);
    lg.fine('PermissionRepositoryImpl.request | $permission: $status');
    yield status[currentPermission]!.toStatus();
  }
}

extension PermissionToPermissionHandler on Permission {
  ph.Permission toPermissionHandler() {
    switch (this) {
      case Permission.contacts:
        return ph.Permission.contacts;
      case Permission.position:
        return ph.Permission.locationWhenInUse;
      case Permission.backgroundPosition:
        return ph.Permission.locationAlways;
    }
  }
}

extension PermissionStatusHandlerToPermissionStatus on ph.PermissionStatus {
  PermissionStatus toStatus() {
    switch (this) {
      case ph.PermissionStatus.permanentlyDenied:
        return PermissionStatus.permanentlyDenied;
      case ph.PermissionStatus.denied:
        return PermissionStatus.denied;
      case ph.PermissionStatus.limited:
      case ph.PermissionStatus.restricted:
        return PermissionStatus.denied;
      case ph.PermissionStatus.granted:
        return PermissionStatus.granted;
    }
  }
}
