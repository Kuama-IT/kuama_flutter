import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/_utils/lg.dart';
import 'package:kuama_flutter/src/features/permissions/entities/permission.dart';
import 'package:kuama_flutter/src/features/permissions/use_cases/can_ask_permission.dart';
import 'package:kuama_flutter/src/features/permissions/use_cases/check_permission.dart';
import 'package:kuama_flutter/src/features/permissions/use_cases/request_permission.dart';
import 'package:kuama_flutter/src/features/permissions/use_cases/update_can_ask_permission.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failure.dart';

part '_permission_event.dart';
part '_permission_state.dart';

/// Request permission using [request].
/// After asking for permission the bloc can go to two states:
///
/// As soon as the bloc is created, it will be in the [PermissionBlocRequesting] state,
/// waiting for it to load. You will find yourself in one of these situations:
/// 1. [PermissionBlocLoaded]
///   Permission was never asked. You can request it
/// 2. [PermissionBlocRequested]
///   Permission has already been requested
///
/// You can apply for permission and you may find yourself in these situations:
/// 1. [PermissionBlocRequestConfirm]
///   The Bloc requires a permit request confirmation. Use [confirmRequest] to confirm the request
/// 2. [PermissionBlocRequested]
///   The bloc has completed successfully, read the status of the permit and act accordingly
///
///
/// - If the permission has the status [PermissionStatus.denied], you can request permission
///   using [request] with [canForce] a true.
/// - If the permission has the status [PermissionStatus.permanentlyDenied] the permission cannot
///   be requested by the bloc. Therefore you should ask the user to enable the permission.
///
/// How can you interact:
/// [PermissionBlocLoaded] -> [load] | [request]
/// [PermissionBlocRequestConfirm] -> [load] | [confirmRequest] | [request] canForce=true
/// [PermissionBlocRequested] -> [load] | [request] canForce=true
/// How it responds to your interactions:
/// [load] -> [PermissionBlocLoaded] | [PermissionBlocRequested]
/// [request] -> [PermissionBlocRequestConfirm] | [PermissionBlocRequested]
/// [confirmRequest] -> [PermissionBlocRequested]
///
class PermissionBloc extends Bloc<PermissionEvent, PermissionBlocState> {
  final CanAskPermission _canAsk = GetIt.I();
  final UpdateCanAskPermission _updateCanAsk = GetIt.I();
  final CheckPermission _check = GetIt.I();
  final RequestPermission _request = GetIt.I();

  final bool _isConfirmRequired;

  @visibleForTesting
  static bool isTesting = false;

  PermissionBloc._({
    required Permission permission,
    bool isConfirmRequired = true,
    @visibleForTesting bool canLoad = true,
  })  : _isConfirmRequired = isConfirmRequired,
        super(PermissionBlocRequesting(permission: permission)) {
    if (!isTesting) load();
  }

  /// Update the bloc state with the new permission status if it has been changed externally
  void load({bool isLazy = false}) => add(LoadPermissionBloc(isLazy: isLazy));

  /// Request the permission managed by the bloc
  /// Use [canForce] to force the request for permission when it has already been requested
  void request({bool isConfirmRequired = true, bool canForce = false}) =>
      add(RequestPermissionBloc(isConfirmRequired: isConfirmRequired, canForce: canForce));

  /// Confirm the permit request
  void confirmRequest(bool canRequest) => add(ConfirmRequestPermissionBloc(canRequest));

  @override
  @protected
  Stream<PermissionBlocState> mapEventToState(PermissionEvent event) async* {
    final state = this.state;

    if (event is LoadPermissionBloc) {
      if (!event.isLazy) yield state.toRequesting();

      yield* _mapRequest(_RequestType.load);
      return;
    }
    if (event is ConfirmRequestPermissionBloc) {
      if (state is! PermissionBlocRequestConfirm) return;

      yield state.toRequesting();

      await _callUpdateCanAsk(event.canRequest);
      yield* _mapRequest(_RequestType.request);
      return;
    }
    if (event is RequestPermissionBloc) {
      if (!event.canForce) {
        if (state is PermissionBlocRequestConfirm || state is PermissionBlocRequested) return;
      }

      yield state.toRequesting();
      if (event.canForce) await _callUpdateCanAsk(true);
      final isConfirmRequired = event.isConfirmRequired ?? _isConfirmRequired;
      yield* _mapRequest(isConfirmRequired ? _RequestType.confirm : _RequestType.request);
      return;
    }
  }

  /// Update the se value of the permit request
  ///
  /// NB: If it fails or succeeds with a wrong outcome, the bloc is not affected by the malfunction
  /// TODO: It continues with the correct functioning even in case of success with wrong response
  Future<void> _callUpdateCanAsk(bool canAsk) async {
    final res = await _updateCanAsk.call(UpdateCanAskPermissionParams(state.permission, canAsk));
    res.fold((failure) {
      // Todo: Show failure
      lg.e(failure);
    }, (canAsk) {
      lg.i('Update can ask permission: $canAsk');
    });
  }

  /// Update the state of the bloc based on the status of the permission (canAsk, status)
  ///
  /// - If the permit is not required, it will be emitted [PermissionBlocRequested]
  /// - If the permission is requestable but is denied, [PermissionBlocRequestConfirm] or
  ///   [PermissionBlocRequested] will be emitted, depending on whether
  ///   confirmation is required [isConfirmRequired]
  ///
  /// In other cases, [PermissionBlocRequested] will be issued with the status of the permit
  /// or [PermissionBlocRequestFailed] if the request for the permit fails
  Stream<PermissionBlocState> _mapRequest(_RequestType type) async* {
    final canRequireRes = await _canAsk.call(state.permission);

    yield await canRequireRes.fold((failure) {
      return state.toRequestFailed(failure: failure);
    }, (canRequest) async {
      if (!canRequest) {
        return state.toRequested(status: PermissionStatus.denied);
      }

      final statusRes = await (type.isRequest ? _request : _check).call(state.permission);

      return statusRes.fold((failure) {
        return state.toRequestFailed(failure: failure);
      }, (status) {
        switch (status) {
          case PermissionStatus.denied:
            switch (type) {
              case _RequestType.load:
                return state.toLoaded();
              case _RequestType.confirm:
                return state.toRequestConfirm();
              case _RequestType.request:
                return state.toRequested(status: status);
            }
          case PermissionStatus.permanentlyDenied:
          case PermissionStatus.granted:
            return state.toRequested(status: status);
        }
      });
    });
  }
}

enum _RequestType { confirm, request, load }

extension _RequestTypeExtension on _RequestType {
  bool get isConfirm => this == _RequestType.confirm;
  bool get isRequest => this == _RequestType.request;
  bool get isLoad => this == _RequestType.load;
}

class PositionPermissionBloc extends PermissionBloc {
  PositionPermissionBloc({
    bool isConfirmRequired = true,
  }) : super._(
          permission: Permission.position,
          isConfirmRequired: isConfirmRequired,
        );

  PositionPermissionBloc._({
    bool isConfirmRequired = true,
    required Permission permission,
  }) : super._(
          permission: permission,
          isConfirmRequired: isConfirmRequired,
        );
}

class BackgroundPositionPermissionBloc extends PositionPermissionBloc {
  BackgroundPositionPermissionBloc({
    bool isConfirmRequired = true,
  }) : super._(
          permission: Permission.backgroundPosition,
          isConfirmRequired: isConfirmRequired,
        );
}

class ContactsPermissionBloc extends PermissionBloc {
  ContactsPermissionBloc({
    bool isConfirmRequired = true,
  }) : super._(
          permission: Permission.contacts,
          isConfirmRequired: isConfirmRequired,
        );
}
