import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';

/// Manage permissions preferences
abstract class PermissionPreferencesRepository {
  const PermissionPreferencesRepository._();

  Future<bool> getCanAsk(Permission permission);

  Future<bool> setCanAsk(Permission permission, bool canAsk);
}
