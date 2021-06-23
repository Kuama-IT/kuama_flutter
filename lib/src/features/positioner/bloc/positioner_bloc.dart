import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/permissions/bloc/permission_bloc.dart';
import 'package:kuama_flutter/src/features/positioner/usecases/get_current_position.dart';
import 'package:kuama_flutter/src/features/positioner/usecases/on_position_changes.dart';
import 'package:kuama_flutter/src/features/positioner/usecases/on_service_changes.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failure.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';

part '_positioner_event.dart';
part '_positioner_state.dart';

class PositionerBloc extends Bloc<PositionerBlocEvent, PositionerBlocState> {
  final OnPositionServiceChanges _onServiceChanges = GetIt.I();
  final GetCurrentPosition _getCurrentLocation = GetIt.I();
  final OnPositionChanges _onPositionChanges = GetIt.I();

  final _subs = CompositeSubscription();

  var _realTimeListenerCount = 0;
  StreamSubscription? _onPositionChangesSub;

  PositionerBloc({
    GeoPoint? lastPosition,
    required PermissionBloc permissionBloc,
    bool isServiceEnabled = false,
  }) : super(PositionerBlocIdle(
          lastPosition: lastPosition,
          hasPermission: permissionBloc.state.isGranted,
          isServiceEnabled: isServiceEnabled,
        )) {
    permissionBloc.stream.distinctRuntimeType().where((state) {
      // Skip all elaborating request states
      return !(state is PermissionBlocRequesting || state is PermissionBlocRequestConfirm);
    }).listen((permissionState) {
      add(_PermissionUpdatePositionerBloc(permissionState));
    }).addTo(_subs);

    _onServiceChanges.call(NoParams()).listen((res) {
      res.fold((failure) {
        // Todo: emit failure
      }, (isServiceEnabled) {
        add(_ServiceUpdatePositionerBloc(isServiceEnabled));
      });
    }).addTo(_subs);
  }

  /// Call it for localize a user. Remember to call [deLocalize] to free up resources
  ///
  /// Enable realtime location if you need to receive location updates all the time
  void localize({bool isRealTimeRequired = false}) =>
      add(LocalizePositionerBloc(isRealTimeRequired: isRealTimeRequired));

  /// It stops listening to the position in realtime when there are no more listeners for it
  ///
  /// It must be called when you were listening to the position in realtime.
  /// There is no need to call it if you weren't listening to the realtime position.
  void deLocalize({bool wasUsingRealTime = false}) =>
      add(DeLocalizePositionerBloc(wasUsingRealTime: wasUsingRealTime));

  @override
  Stream<PositionerBlocState> mapEventToState(PositionerBlocEvent event) {
    if (event is _PermissionUpdatePositionerBloc) {
      return _mapPermissionUpdate(event.state);
    }
    if (event is _ServiceUpdatePositionerBloc) {
      return _mapServiceUpdate(event.isServiceEnabled);
    }

    // You do not have the necessary credentials to be able to locate the user
    if (!state.canLocalize) {
      return Stream.empty();
    }

    if (event is LocalizePositionerBloc) {
      return _mapLocalize(event);
    }
    if (event is _PositionUpdatePositionerBloc) {
      return Stream.value(event.state);
    }
    if (event is DeLocalizePositionerBloc) {
      return _mapDeLocalize(event);
    }
    throw UnimplementedError('$event');
  }

  Future<void> _restoreBloc() async {
    _realTimeListenerCount = 0;
    await _onPositionChangesSub?.cancel();
  }

  /// Update current status based on permission state
  Stream<PositionerBlocState> _mapPermissionUpdate(PermissionBlocState permissionState) async* {
    final state = this.state;

    final hasPermission = permissionState.isGranted;

    // Permission has been revoked, clean up and update the bloc state
    if (!hasPermission) {
      await _restoreBloc();
      yield state.toIdle(hasPermission: false);
      return;
    }
    // Permission has been granted, update the bloc state
    if (!state.hasPermission) {
      yield state.toIdle(hasPermission: true);
      return;
    }
    // No major changes. The bloc already has permission
  }

  /// Update current status based on service status
  Stream<PositionerBlocState> _mapServiceUpdate(bool isServiceEnabled) async* {
    // Service is disabled, clean up and update the bloc state
    if (!isServiceEnabled) {
      await _restoreBloc();
      yield state.toIdle(isServiceEnabled: false);
      return;
    }
    // Service is enabled, update the bloc state
    if (!state.isServiceEnabled) {
      yield state.toIdle(isServiceEnabled: true);
      return;
    }
    // No major changes. The bloc already has service status updated
  }

  /// Resolves the location request
  ///
  /// If only the current position is requested, it will output the current position once
  /// If realtime position is requested it will output current position many times
  ///
  /// If realtime position is active and you have requested only the current position wait for the next realtime position
  Stream<PositionerBlocState> _mapLocalize(LocalizePositionerBloc event) async* {
    if (event.isRealTimeRequired) {
      _realTimeListenerCount++;
    }

    // If bloc is not listening to realtime position, it will shortly output the current position
    if (_realTimeListenerCount <= 0) {
      yield state.toLocating(isRealTime: false);

      final res = await _getCurrentLocation.call(NoParams()).single;
      yield res.fold((failure) {
        return state.toFailed(failure: failure);
      }, (position) {
        return state.toLocated(isRealTime: false, currentPosition: position);
      });
      return;
    }

    // Already listen realtime position events
    if (_onPositionChangesSub != null) {
      return;
    }

    yield state.toLocating(isRealTime: true);

    // Listen realtime position
    _onPositionChangesSub = _onPositionChanges.call(NoParams()).listen((res) {
      final nextState = res.fold((failure) {
        return state.toFailed(failure: failure);
      }, (position) {
        return state.toLocated(isRealTime: true, currentPosition: position);
      });
      add(_PositionUpdatePositionerBloc(nextState));
    });
  }

  /// Stop listening to the actual location if there are no more listeners for it
  Stream<PositionerBlocState> _mapDeLocalize(DeLocalizePositionerBloc event) async* {
    if (event.wasUsingRealTime) {
      _realTimeListenerCount--;
    }
    // Other listeners are listening to the position in realtime
    if (_realTimeListenerCount >= 1) {
      return;
    }

    // Nobody is listening to the real position
    await _onPositionChangesSub?.cancel();
    yield state.toIdle(hasPermission: true, isServiceEnabled: true);
  }

  @override
  Future<void> close() {
    _onPositionChangesSub?.cancel();
    _subs.dispose();
    return super.close();
  }
}
