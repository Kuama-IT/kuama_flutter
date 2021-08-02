import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuama_flutter/src/features/positioner/bloc/positioner_bloc.dart';
import 'package:kuama_flutter/src/shared/widgets/change_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:pure_extensions/pure_extensions.dart';

class LocalizePositionBlocListener extends SingleChildStatefulWidget {
  /// Define if realtime user tracking is required
  final bool isRealTimeRequired;

  /// Just listen to the position in realTime.
  /// If null depends on [isRealTimeRequired]
  final bool? canWaitRealTime;

  /// If [true] it outputs the position of the current state
  final bool canEmitCurrentPosition;
  final void Function(BuildContext context, GeoPoint position)? onPosition;

  const LocalizePositionBlocListener({
    Key? key,
    this.isRealTimeRequired = false,
    this.canWaitRealTime,
    this.canEmitCurrentPosition = false,
    this.onPosition,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  _LocalizePositionBlocListenerState createState() => _LocalizePositionBlocListenerState();
}

class _LocalizePositionBlocListenerState extends SingleChildState<LocalizePositionBlocListener> {
  /// Marker to define if I am located
  bool _isLocalized = false;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final positionerBloc = context.read<PositionerBloc>();

    final canWaitRealTime = widget.canWaitRealTime ?? widget.isRealTimeRequired;

    return MultiProvider(
      providers: [
        BlocChangeHandler<PositionerBloc, PositionerBlocState>(
          bloc: positionerBloc,
          canCallImmediately: true,
          onAcquired: (context, state) {
            // Request location if possible
            if (state.canLocalize) {
              _isLocalized = true;
              positionerBloc.localize(isRealTimeRequired: widget.isRealTimeRequired);
            }
          },
          onLost: (context, state) {
            // If I was localized remove localization
            if (state.canLocalize && _isLocalized) {
              positionerBloc.deLocalize(wasUsingRealTime: widget.isRealTimeRequired);
            }
            _isLocalized = false;
          },
        ),
        BlocListener<PositionerBloc, PositionerBlocState>(
          bloc: positionerBloc,
          listenWhen: (prev, curr) => prev.canLocalize != curr.canLocalize,
          listener: (context, state) {
            // Request location if possible otherwise mark me as unLocated
            if (state.canLocalize) {
              positionerBloc.localize(isRealTimeRequired: widget.isRealTimeRequired);
              _isLocalized = true;
            } else {
              _isLocalized = false;
            }
          },
        ),
        if (widget.onPosition != null)
          if (canWaitRealTime) ...[
            if (widget.canEmitCurrentPosition)
              BlocChangeHandler<PositionerBloc, PositionerBlocState>(
                bloc: positionerBloc,
                onAcquired: (context, state) {
                  if (state is PositionerBlocLocated) {
                    widget.onPosition?.call(context, state.currentPosition);
                  }
                },
              ),
            BlocListener<PositionerBloc, PositionerBlocState>(
              bloc: positionerBloc,
              listener: (context, state) {
                if (state is PositionerBlocLocated) {
                  widget.onPosition!(context, state.currentPosition);
                }
              },
            ),
          ] else ...[
            if (widget.canEmitCurrentPosition)
              BlocChangeHandler<PositionerBloc, PositionerBlocState>(
                bloc: positionerBloc,
                onAcquired: (context, state) {
                  final position = state.lastPosition;
                  if (position != null) widget.onPosition!(context, position);
                },
              ),
            BlocListener<PositionerBloc, PositionerBlocState>(
              bloc: positionerBloc,
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
