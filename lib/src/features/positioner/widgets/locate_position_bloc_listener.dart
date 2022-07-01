import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuama_flutter/src/features/positioner/bloc/position_bloc.dart';
import 'package:kuama_flutter/src/shared/widgets/change_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:pure_extensions/pure_extensions.dart';

class LocatePositionBlocListener extends SingleChildStatefulWidget {
  /// Define if realtime user tracking is required
  final bool isRealTimeRequired;

  /// Just listen to the position in realTime.
  /// If null depends on [canTrack]
  final bool? canWaitRealTime;

  /// If [true] it outputs the position of the current state
  final bool canEmitCurrentPosition;
  final void Function(BuildContext context, GeoPoint position)? onPosition;

  const LocatePositionBlocListener({
    Key? key,
    this.isRealTimeRequired = false,
    this.canWaitRealTime,
    this.canEmitCurrentPosition = false,
    this.onPosition,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  SingleChildState<LocatePositionBlocListener> createState() =>
      _LocalizePositionBlocListenerState();
}

class _LocalizePositionBlocListenerState extends SingleChildState<LocatePositionBlocListener> {
  late PositionBloc _positionBloc;

  @override
  void initState() {
    super.initState();
    _positionBloc = context.read();
    _locate(widget.isRealTimeRequired);
  }

  @override
  void didUpdateWidget(covariant LocatePositionBlocListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    // TODO: Check PositionBloc dependency changed
    if (widget.isRealTimeRequired != oldWidget.isRealTimeRequired) {
      _unLocate(oldWidget.isRealTimeRequired);
      _locate(widget.isRealTimeRequired);
    }
  }

  @override
  void dispose() {
    _unLocate(widget.isRealTimeRequired);
    super.dispose();
  }

  void _locate(bool canTrack) {
    if (canTrack) {
      _positionBloc.track();
    } else {
      _positionBloc.locate();
    }
  }

  void _unLocate(bool canTrack) {
    if (canTrack) {
      _positionBloc.unTrack();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final canWaitRealTime = widget.canWaitRealTime ?? widget.isRealTimeRequired;

    return MultiProvider(
      providers: [
        if (widget.onPosition != null)
          if (canWaitRealTime) ...[
            if (widget.canEmitCurrentPosition)
              BlocChangeHandler<PositionBloc, PositionBlocState>(
                bloc: _positionBloc,
                onAcquired: (context, state) {
                  if (state is PositionBlocLocated) {
                    widget.onPosition?.call(context, state.currentPosition);
                  }
                },
              ),
            BlocListener<PositionBloc, PositionBlocState>(
              bloc: _positionBloc,
              listener: (context, state) {
                if (state is PositionBlocLocated) {
                  widget.onPosition!(context, state.currentPosition);
                }
              },
            ),
          ] else ...[
            if (widget.canEmitCurrentPosition)
              BlocChangeHandler<PositionBloc, PositionBlocState>(
                bloc: _positionBloc,
                onAcquired: (context, state) {
                  final position = state.lastPosition;
                  if (position != null) widget.onPosition!(context, position);
                },
              ),
            BlocListener<PositionBloc, PositionBlocState>(
              bloc: _positionBloc,
              listener: (context, state) {
                final position = state.lastPosition;
                if (position != null) widget.onPosition!(context, position);
              },
            ),
          ],
      ],
      child: child,
    );
  }
}

class PositionBlocLocator extends StatelessWidget {
  const PositionBlocLocator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
