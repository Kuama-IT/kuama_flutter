part of 'permission_bloc.dart';

abstract class PermissionBlocState extends Equatable {
  final Permission permission;

  const PermissionBlocState({required this.permission});

  bool get isRequesting => this is PermissionBlocRequesting;

  bool get canRequest {
    final state = this;
    if (state is PermissionBlocRequested) {
      switch (state.status) {
        case PermissionStatus.permanentlyDenied:
          return false;
        case PermissionStatus.denied:
          return true;
        case PermissionStatus.granted:
          return false;
      }
    } else if (state is PermissionBlocRequesting) {
      return false;
    }
    return true;
  }

  bool get canConfirmRequest => this is PermissionBlocRequestConfirm;

  bool get canForceRequest {
    final state = this;
    if (state is PermissionBlocRequested) {
      switch (state.status) {
        case PermissionStatus.permanentlyDenied:
        case PermissionStatus.denied:
          return true;
        case PermissionStatus.granted:
          return false;
      }
    } else if (state is PermissionBlocRequesting) {
      return false;
    }
    return true;
  }

  bool get isPermanentlyDenied {
    final state = this;
    return state is PermissionBlocRequested && state.status.isPermanentlyDenied;
  }

  bool get isDenied {
    final state = this;
    return state is PermissionBlocRequested && state.status.isDenied;
  }

  bool get isGranted {
    final state = this;
    return state is PermissionBlocRequested && state.status.isGranted;
  }

  PermissionBlocState toLoaded() => PermissionBlocLoaded(permission: permission);

  PermissionBlocState toRequestConfirm() => PermissionBlocRequestConfirm(permission: permission);

  PermissionBlocState toRequesting() => PermissionBlocRequesting(permission: permission);

  PermissionBlocState toRequestFailed({required Failure failure}) {
    return PermissionBlocRequestFailed(
      permission: permission,
      failure: failure,
    );
  }

  PermissionBlocState toRequested({required PermissionStatus status}) {
    return PermissionBlocRequested(
      permission: permission,
      status: status,
    );
  }

  @override
  bool? get stringify => true;
}

/// The bloc has been loaded. Now you can interact with it
class PermissionBlocLoaded extends PermissionBlocState {
  PermissionBlocLoaded({required Permission permission}) : super(permission: permission);

  @override
  List<Object?> get props => [permission];
}

/// It is processing the request wait for a later status to interact with the bloc
class PermissionBlocRequesting extends PermissionBlocState {
  PermissionBlocRequesting({required Permission permission}) : super(permission: permission);

  @override
  List<Object?> get props => [permission];
}

/// A failed state
class PermissionBlocRequestFailed extends PermissionBlocState {
  final Failure failure;

  PermissionBlocRequestFailed({
    required Permission permission,
    required this.failure,
  }) : super(permission: permission);

  @override
  List<Object?> get props => [permission, failure];
}

/// A state in which a confirmation of the request by the user is required
class PermissionBlocRequestConfirm extends PermissionBlocState {
  PermissionBlocRequestConfirm({required Permission permission}) : super(permission: permission);

  @override
  List<Object?> get props => [permission];
}

/// A status of success or stalemate based on the status of the permission
class PermissionBlocRequested extends PermissionBlocState {
  final PermissionStatus status;

  PermissionBlocRequested({
    required Permission permission,
    required this.status,
  }) : super(permission: permission);

  @override
  List<Object?> get props => [permission, status];
}
