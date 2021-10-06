import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';
import 'package:kuama_flutter/src/features/permissions/repositories/permission_preferences_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failures/dart_failures.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';

/// Check if the permit can be requested
abstract class CanAskPermission extends UseCase<Permission, bool> {
  CanAskPermission();

  factory CanAskPermission.preferences() => _PreferencesCanAskPermission();
}

/// [CanAskPermission] Use the repository [PermissionPreferencesRepository]
class _PreferencesCanAskPermission extends CanAskPermission {
  final PermissionPreferencesRepository prefRepo = GetIt.I();

  @override
  Future<Either<Failure, bool>> tryCall(Permission permission) async {
    return prefRepo.getCanAsk(permission).toRight();
  }
}
