import 'package:kuama_flutter/src/features/app_pages/repositories/app_pages_repository.dart';
import 'package:kuama_flutter/src/shared/library_exports.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

class AppPagesRepositoryImpl implements AppPagesRepository {
  final PermissionHandlerPlatform permissionHandler = GetIt.I();

  @override
  Future<bool> openSettings() async {
    return await permissionHandler.openAppSettings();
  }
}
