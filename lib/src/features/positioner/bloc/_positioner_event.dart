part of 'positioner_bloc.dart';

abstract class PositionerBlocEvent extends Equatable {
  const PositionerBlocEvent();

  @override
  bool? get stringify => true;
}

/// [PositionerBloc.localize]
class LocalizePositionerBloc extends PositionerBlocEvent {
  final bool isRealTimeRequired;

  LocalizePositionerBloc({this.isRealTimeRequired = false});

  @override
  List<Object?> get props => [isRealTimeRequired];
}

/// [PositionerBloc.deLocalize]
class DeLocalizePositionerBloc extends PositionerBlocEvent {
  final bool wasUsingRealTime;

  DeLocalizePositionerBloc({this.wasUsingRealTime = false});

  @override
  List<Object?> get props => [wasUsingRealTime];
}

/// Event to update the status of the position permission
class _PermissionUpdatePositionerBloc extends PositionerBlocEvent {
  final PermissionBlocState state;

  _PermissionUpdatePositionerBloc(this.state);

  @override
  List<Object?> get props => [state];
}

/// Event to update the service status of the position
class _ServiceUpdatePositionerBloc extends PositionerBlocEvent {
  final bool isServiceEnabled;

  _ServiceUpdatePositionerBloc(this.isServiceEnabled);

  @override
  List<Object?> get props => [isServiceEnabled];
}

/// Event to update the realtime position
class _PositionUpdatePositionerBloc extends PositionerBlocEvent {
  final PositionerBlocState state;

  _PositionUpdatePositionerBloc(this.state);

  @override
  List<Object?> get props => [state];
}
