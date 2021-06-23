part of 'positioner_bloc.dart';

abstract class PositionerBlocState extends Equatable {
  final GeoPoint? lastPosition;

  const PositionerBlocState({required this.lastPosition});

  bool get hasPermission {
    final state = this;
    if (state is PositionerBlocIdle) {
      return state.hasPermission;
    }
    return true;
  }

  bool get isServiceEnabled {
    final state = this;
    if (state is PositionerBlocIdle) {
      return state.isServiceEnabled;
    }
    return true;
  }

  /// Check if you can call [PositionerBloc.localize].
  /// You must have permission and active service
  bool get canLocalize => hasPermission && isServiceEnabled;

  PositionerBlocState toIdle({GeoPoint? position, bool? hasPermission, bool? isServiceEnabled}) {
    return PositionerBlocIdle(
      lastPosition: position ?? lastPosition,
      hasPermission: hasPermission ?? this.hasPermission,
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
    );
  }

  PositionerBlocLocating toLocating({required bool isRealTime}) {
    return PositionerBlocLocating(
      lastPosition: lastPosition,
      isRealTime: isRealTime,
    );
  }

  PositionerBlocState toFailed({required Failure failure}) {
    return PositionerBlocFailed(lastPosition: lastPosition, failure: failure);
  }

  PositionerBlocState toLocated({
    required bool isRealTime,
    required GeoPoint currentPosition,
  }) {
    return PositionerBlocLocated(
      isRealTime: isRealTime,
      currentPosition: currentPosition,
    );
  }

  @override
  bool get stringify => true;
}

/// It is waiting for a localization request that can only be requested when [canLocalize] is true
class PositionerBlocIdle extends PositionerBlocState {
  @override
  final bool hasPermission;
  @override
  final bool isServiceEnabled;

  PositionerBlocIdle({
    required GeoPoint? lastPosition,
    required this.hasPermission,
    required this.isServiceEnabled,
  }) : super(lastPosition: lastPosition);

  @override
  List<Object?> get props => [lastPosition, hasPermission, isServiceEnabled];
}

/// It is locating the user
class PositionerBlocLocating extends PositionerBlocState {
  final bool isRealTime;

  PositionerBlocLocating({
    required GeoPoint? lastPosition,
    required this.isRealTime,
  }) : super(lastPosition: lastPosition);

  @override
  List<Object?> get props => [lastPosition, isRealTime];
}

/// Localization failed
class PositionerBlocFailed extends PositionerBlocState {
  final Failure failure;

  PositionerBlocFailed({
    required GeoPoint? lastPosition,
    required this.failure,
  }) : super(lastPosition: lastPosition);

  @override
  List<Object?> get props => [lastPosition, failure];
}

/// The user has been located
/// Other positions will be issued if [isRealTime] is true
class PositionerBlocLocated extends PositionerBlocState {
  final bool isRealTime;
  final GeoPoint currentPosition;

  PositionerBlocLocated({
    required this.isRealTime,
    required this.currentPosition,
  }) : super(lastPosition: currentPosition);

  @override
  List<Object?> get props => [lastPosition, isRealTime, currentPosition];
}
