import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/_utils/lg.dart';
import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';
import 'package:kuama_flutter/src/features/permissions/repositories/permission_repository.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart'
    as ph;
import 'package:synchronized/synchronized.dart';

/// [PermissionRepository]
///
/// 1.The `locationAlways` permission can not be requested directly, the user has to request the `locationWhenInUse` permission first.
///   Accepting this permission by clicking on the 'Allow While Using App' gives the user the possibility to request the `locationAlways` permission.
///   This will then bring up another permission popup asking you to `Keep Only While Using` or to `Change To Always Allow`.
class PermissionRepositoryImpl implements PermissionRepository {
  final ph.PermissionHandlerPlatform permissionHandler = GetIt.I();

  /// You can only make one request at a time
  static final _locker = Lock();

  /// [PermissionRepository.check]
  @override
  Future<PermissionStatus> check(Permission permission) async {
    final pluginPermission = permission.toPermissionHandler();
    final pluginStatus = await permissionHandler.checkPermissionStatus(pluginPermission);
    final status = pluginStatus.toStatus();
    lg.v(
        'PermissionRepositoryImpl.check | $permission -> $pluginPermission | $pluginStatus -> $status');
    return status;
  }

  /// [PermissionRepository.request]
  @override
  Future<PermissionStatus> request(Permission permission) async {
    return await _locker.synchronized(() async {
      final pluginPermission = permission.toPermissionHandler();
      final pluginStatus = await _request(pluginPermission);
      final status = pluginStatus.toStatus();
      lg.v(
          'PermissionRepositoryImpl.request | $permission -> $pluginPermission | $pluginStatus -> $status');
      return status;
    });
  }

  Future<ph.PermissionStatus> _request(ph.Permission permission) async {
    // See point (1)
    if (permission == ph.Permission.locationAlways) {
      final status = await permissionHandler.checkPermissionStatus(ph.Permission.locationWhenInUse);

      if (!status.isGranted) {
        final mapStatus = await permissionHandler.requestPermissions([
          ph.Permission.locationWhenInUse,
        ]);

        final status = mapStatus[ph.Permission.locationWhenInUse]!;

        if (!status.isGranted) return status;
      }

      final mapStatus = await permissionHandler.requestPermissions([ph.Permission.locationAlways]);
      return mapStatus[ph.Permission.locationAlways]!;
    }
    final mapStatus = await permissionHandler.requestPermissions([permission]);
    return mapStatus[permission]!;
  }
}

extension _PermissionToPermissionHandler on Permission {
  ph.Permission toPermissionHandler() {
    switch (this) {
      case Permission.contacts:
        return ph.Permission.contacts;
      case Permission.position:
        return ph.Permission.locationWhenInUse;
      case Permission.backgroundPosition:
        return ph.Permission.locationAlways;
      case Permission.notification:
        return ph.Permission.notification;
      case Permission.camera:
        return ph.Permission.camera;
      case Permission.storage:
        return ph.Permission.storage;
    }
  }
}

extension _PermissionStatusHandlerToPermissionStatus on ph.PermissionStatus {
  PermissionStatus toStatus() {
    switch (this) {
      case ph.PermissionStatus.permanentlyDenied:
        return PermissionStatus.permanentlyDenied;
      case ph.PermissionStatus.denied:
      case ph.PermissionStatus.limited:
      case ph.PermissionStatus.restricted:
        return PermissionStatus.denied;
      case ph.PermissionStatus.granted:
        return PermissionStatus.granted;
    }
  }
}
