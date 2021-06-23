import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuama_flutter/src/features/positioner/bloc/positioner_bloc.dart';
import 'package:kuama_flutter/src/shared/widgets/change_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:pure_extensions/pure_extensions.dart';

class LocalizePositionBlocListener extends SingleChildStatelessWidget {
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
  Widget buildWithChild(BuildContext context, Widget? child) {
    final positionerBloc = context.read<PositionerBloc>();

    final canWaitRealTime = this.canWaitRealTime ?? isRealTimeRequired;

    return MultiProvider(
      providers: [
        BlocChangeHandler<PositionerBloc, PositionerBlocState>(
          bloc: positionerBloc,
          canCallImmediately: true,
          onAcquired: (context, state) {
            if (state.canLocalize) {
              positionerBloc.localize(isRealTimeRequired: isRealTimeRequired);
            }
          },
          onLost: (context, state) {
            positionerBloc.deLocalize(wasUsingRealTime: isRealTimeRequired);
          },
        ),
        BlocListener<PositionerBloc, PositionerBlocState>(
          bloc: positionerBloc,
          listenWhen: (prev, curr) => prev.canLocalize != curr.canLocalize,
          listener: (context, state) {
            positionerBloc.localize(isRealTimeRequired: isRealTimeRequired);
          },
        ),
        if (onPosition != null)
          if (canWaitRealTime) ...[
            if (canEmitCurrentPosition)
              BlocChangeHandler<PositionerBloc, PositionerBlocState>(
                bloc: positionerBloc,
                onAcquired: (context, state) {
                  if (state is PositionerBlocLocated) {
                    onPosition?.call(context, state.currentPosition);
                  }
                },
              ),
            BlocListener<PositionerBloc, PositionerBlocState>(
              bloc: positionerBloc,
              listener: (context, state) {
                if (state is PositionerBlocLocated) {
                  onPosition!(context, state.currentPosition);
                }
              },
            ),
          ] else ...[
            if (canEmitCurrentPosition)
              BlocChangeHandler<PositionerBloc, PositionerBlocState>(
                bloc: positionerBloc,
                onAcquired: (context, state) {
                  final position = state.lastPosition;
                  if (position != null) onPosition!(context, position);
                },
              ),
            BlocListener<PositionerBloc, PositionerBlocState>(
              bloc: positionerBloc,
              listener: (context, state) {
                final position = state.lastPosition;
                if (position != null) onPosition!(context, position);
              },
            ),
          ],
      ],
      child: child,
    );
  }
}
