import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/kuama_flutter.dart';
import 'package:kuama_flutter/permissions.dart';
import 'package:kuama_flutter/positioner.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:test/test.dart';

import 'positioner_bloc_test.mocks.dart';

enum EmissionType { none, acquire, alreadyHas }

@GenerateMocks([
  CheckPositionService,
  OnPositionServiceChanges,
  GetCurrentPosition,
  OnPositionChanges,
  PositionPermissionBloc,
])
void main() {
  late MockCheckPositionService mockCheckService;
  late MockOnPositionServiceChanges mockOnServiceChanges;
  late MockGetCurrentPosition mockGetCurrent;
  late MockOnPositionChanges mockOnPositionChanges;

  late MockPositionPermissionBloc mockPermissionBloc;

  late PositionerBloc bloc;

  final tPermission = Permission.position;

  setUp(() {
    GetIt.instance
      ..reset()
      ..registerSingleton<CheckPositionService>(mockCheckService = MockCheckPositionService())
      ..registerSingleton<OnPositionServiceChanges>(
          mockOnServiceChanges = MockOnPositionServiceChanges())
      ..registerSingleton<GetCurrentPosition>(mockGetCurrent = MockGetCurrentPosition())
      ..registerSingleton<OnPositionChanges>(mockOnPositionChanges = MockOnPositionChanges());
  });

  void init({
    EmissionType permission = EmissionType.none,
    EmissionType service = EmissionType.none,
  }) {
    mockPermissionBloc = MockPositionPermissionBloc();

    when(mockPermissionBloc.state).thenReturn(permission == EmissionType.alreadyHas
        ? PermissionBlocRequested(permission: tPermission, status: PermissionStatus.granted)
        : PermissionBlocRequested(permission: tPermission, status: PermissionStatus.denied));
    when(mockPermissionBloc.stream).thenAnswer((_) async* {
      if (permission == EmissionType.acquire) {
        yield PermissionBlocRequested(permission: tPermission, status: PermissionStatus.granted);
      }
    });
    when(mockCheckService.call(NoParams())).thenAnswer((realInvocation) async {
      return Right(service == EmissionType.alreadyHas);
    });
    when(mockOnServiceChanges.call(NoParams())).thenAnswer((_) async* {
      if (service == EmissionType.acquire) {
        yield Right(true);
      }
    });

    bloc = PositionerBloc(
      permissionBloc: mockPermissionBloc,
    );

    expect(
      bloc.state,
      PositionerBlocIdle(
        lastPosition: null,
        hasPermission: permission == EmissionType.alreadyHas,
        isServiceEnabled: false,
      ),
    );
  }

  group('Test PositionerBloc', () {
    test('Update the bloc when permission has been granted', () async {
      init(permission: EmissionType.acquire);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          PositionerBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: false,
          ),
        ]),
      );
    });

    // test('Update the bloc when service is enabled', () async {
    //   init(service: EmissionType.acquire);
    //
    //   await expectLater(
    //     bloc.stream,
    //     emitsInOrder([
    //       PositionerBlocIdle(
    //         lastPosition: null,
    //         hasPermission: false,
    //         isServiceEnabled: true,
    //       ),
    //     ]),
    //   );
    // });

    test('Update the bloc when has permission and service is enabled', () async {
      init(permission: EmissionType.acquire, service: EmissionType.acquire);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          PositionerBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: false,
          ),
          PositionerBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: true,
          ),
        ]),
      );
    });

    test('A listener requests the current position', () async {
      init(permission: EmissionType.alreadyHas, service: EmissionType.alreadyHas);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          PositionerBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: true,
          ),
        ]),
      );

      when(mockGetCurrent.call(NoParams())).thenAnswer((_) async {
        return Right(GeoPoint(0.0, 0.0));
      });

      bloc.localize();

      await expectLater(
        bloc.stream,
        emitsInOrder([
          PositionerBlocLocating(
            isRealTime: false,
            lastPosition: null,
          ),
          PositionerBlocLocated(
            isRealTime: false,
            currentPosition: GeoPoint(0.0, 0.0),
          ),
        ]),
      );

      bloc.deLocalize();

      expect(
        bloc.stream,
        emitsInOrder([
          PositionerBlocIdle(
            lastPosition: GeoPoint(0.0, 0.0),
            hasPermission: true,
            isServiceEnabled: true,
          ),
          emitsDone,
        ]),
      );

      await bloc.close();
    });

    test('A listener requests the position in realtime', () async {
      init(permission: EmissionType.alreadyHas, service: EmissionType.alreadyHas);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          PositionerBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: true,
          ),
        ]),
      );

      when(mockGetCurrent.call(NoParams())).thenAnswer((_) async {
        return Right(GeoPoint(1.0, 0.0));
      });
      when(mockOnPositionChanges.call(NoParams())).thenAnswer((_) async* {
        yield Right(GeoPoint(0.0, 0.0));
        await Future.delayed(const Duration());
        yield Right(GeoPoint(1.0, 1.0));
      });

      bloc.localize(isRealTimeRequired: true);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          PositionerBlocLocating(
            isRealTime: true,
            lastPosition: null,
          ),
          PositionerBlocLocated(
            isRealTime: true,
            currentPosition: GeoPoint(1.0, 0.0),
          ),
          PositionerBlocLocated(
            isRealTime: true,
            currentPosition: GeoPoint(0.0, 0.0),
          ),
        ]),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          PositionerBlocLocated(
            isRealTime: true,
            currentPosition: GeoPoint(1.0, 1.0),
          ),
        ]),
      );

      bloc.deLocalize(wasUsingRealTime: true);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          PositionerBlocIdle(
            lastPosition: GeoPoint(1.0, 1.0),
            hasPermission: true,
            isServiceEnabled: true,
          ),
        ]),
      );

      expect(
        bloc.stream,
        emitsInOrder([
          emitsDone,
        ]),
      );

      await bloc.close();
    });

    test('More listeners are registered, manage as if it were one', () async {
      init(permission: EmissionType.alreadyHas, service: EmissionType.alreadyHas);
      bloc.emit(PositionerBlocIdle(
        lastPosition: null,
        hasPermission: true,
        isServiceEnabled: true,
      ));

      when(mockGetCurrent.call(NoParams())).thenAnswer((_) async {
        return Right(GeoPoint(0.0, 0.0));
      });
      when(mockOnPositionChanges.call(NoParams())).thenAnswer((_) async* {
        yield Right(GeoPoint(0.0, 0.0));
      });

      bloc.localize(isRealTimeRequired: true);
      bloc.localize();
      bloc.localize(isRealTimeRequired: true);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          PositionerBlocLocating(
            isRealTime: true,
            lastPosition: null,
          ),
          PositionerBlocLocated(
            isRealTime: true,
            currentPosition: GeoPoint(0.0, 0.0),
          ),
        ]),
      );

      verify(mockOnPositionChanges.call(NoParams())).called(1);

      bloc.deLocalize();
      bloc.deLocalize(wasUsingRealTime: true);
      await Future.delayed(const Duration(milliseconds: 10));
      bloc.deLocalize(wasUsingRealTime: true);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          PositionerBlocIdle(
            lastPosition: GeoPoint(0.0, 0.0),
            hasPermission: true,
            isServiceEnabled: true,
          ),
        ]),
      );

      expect(
        bloc.stream,
        emitsInOrder([
          emitsDone,
        ]),
      );

      await bloc.close();
    });
  });
}
