part of 'permission_bloc.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  bool? get stringify => true;
}

/// [PermissionBloc.load]
class LoadPermissionBloc extends PermissionEvent {
  final bool isLazy;

  const LoadPermissionBloc({this.isLazy = false});

  @override
  List<Object?> get props => [isLazy];
}

/// [PermissionBloc.confirmRequest]
class ConfirmRequestPermissionBloc extends PermissionEvent {
  final bool canRequest;

  const ConfirmRequestPermissionBloc(this.canRequest);

  @override
  List<Object?> get props => const [];
}

/// [PermissionBloc.request]
class RequestPermissionBloc extends PermissionEvent {
  final bool canForce;
  final bool? isConfirmRequired;

  const RequestPermissionBloc({this.canForce = false, this.isConfirmRequired});

  @override
  List<Object?> get props => [canForce, isConfirmRequired];
}
