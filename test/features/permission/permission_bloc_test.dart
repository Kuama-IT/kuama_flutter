import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/permissions.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'permission_bloc_test.mocks.dart';

@GenerateMocks([
  CanAskPermission,
  UpdateCanAskPermission,
  CheckPermission,
  RequestPermission,
])
void main() {
  late MockCanAskPermission mockCanAsk;
  late MockUpdateCanAskPermission mockUpdateCanAsk;
  late MockCheckPermission mockCheck;
  late MockRequestPermission mockRequest;

  late PermissionBloc bloc;

  final tPermission = Permission.contacts;

  setUp(() {
    GetIt.instance
      ..reset()
      ..registerSingleton<CanAskPermission>(mockCanAsk = MockCanAskPermission())
      ..registerSingleton<UpdateCanAskPermission>(mockUpdateCanAsk = MockUpdateCanAskPermission())
      ..registerSingleton<CheckPermission>(mockCheck = MockCheckPermission())
      ..registerSingleton<RequestPermission>(mockRequest = MockRequestPermission());

    PermissionBloc.isTesting = true;
    bloc = ContactsPermissionBloc();
  });

  group('Test PermissionBloc', () {
    group('Load', () {
      test('Load->ConfirmNegated', () async {
        when(mockCanAsk.call(any)).thenAnswer((_) async {
          await Future.delayed(const Duration());
          return Right(false);
        });

        bloc.load();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            PermissionBlocRequesting(
              permission: tPermission,
            ),
            PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.denied,
            ),
          ]),
        );
      });

      test('Load->PermissionPermanentlyDenied', () async {
        when(mockCanAsk.call(any)).thenAnswer((_) async {
          await Future.delayed(const Duration());
          return Right(true);
        });
        when(mockCheck.call(any)).thenAnswer((_) async {
          return Right(PermissionStatus.permanentlyDenied);
        });

        bloc.load();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            PermissionBlocRequesting(
              permission: tPermission,
            ),
            PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.permanentlyDenied,
            ),
          ]),
        );
      });

      test('Load->PermissionDenied', () async {
        when(mockCanAsk.call(any)).thenAnswer((_) async {
          await Future.delayed(const Duration());
          return Right(true);
        });
        when(mockCheck.call(any)).thenAnswer((_) async {
          return Right(PermissionStatus.denied);
        });

        bloc.load();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            PermissionBlocRequesting(
              permission: tPermission,
            ),
            PermissionBlocLoaded(
              permission: Permission.contacts,
            ),
          ]),
        );
      });

      test('Load->PermissionGranted', () async {
        when(mockCanAsk.call(any)).thenAnswer((_) async {
          await Future.delayed(const Duration());
          return Right(true);
        });
        when(mockCheck.call(any)).thenAnswer((_) async {
          return Right(PermissionStatus.granted);
        });

        bloc.load();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            PermissionBlocRequesting(
              permission: tPermission,
            ),
            PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.granted,
            ),
          ]),
        );
      });
    });

    group('Request', () {
      test('Request->RequireNegated->PermissionDenied', () async {
        when(mockCanAsk.call(any)).thenAnswer((_) async {
          await Future.delayed(const Duration());
          return Right(false);
        });

        bloc.request();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            PermissionBlocRequesting(
              permission: tPermission,
            ),
            PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.denied,
            ),
          ]),
        );
      });

      test('Request->RequireGranted->PermissionDenied', () async {
        when(mockCanAsk.call(any)).thenAnswer((_) async {
          return Right(true);
        });
        when(mockCheck.call(any)).thenAnswer((_) async {
          return Right(PermissionStatus.denied);
        });

        bloc.request();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            PermissionBlocRequesting(
              permission: tPermission,
            ),
            PermissionBlocRequestConfirm(
              permission: Permission.contacts,
            ),
          ]),
        );
      });

      test('Request->RequireGranted->PermissionGranted', () async {
        when(mockCanAsk.call(any)).thenAnswer((_) async {
          return Right(true);
        });
        when(mockCheck.call(any)).thenAnswer((_) async {
          return Right(PermissionStatus.granted);
        });

        bloc.request();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            PermissionBlocRequesting(
              permission: tPermission,
            ),
            PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.granted,
            ),
          ]),
        );
      });
    });

    group('ConfirmRequest', () {
      test('RequireConfirm->ConfirmFailed->PermissionDenied', () async {
        bloc.emit(PermissionBlocRequestConfirm(
          permission: Permission.contacts,
        ));

        when(mockUpdateCanAsk.call(any)).thenAnswer((_) async {
          return Right(false);
        });
        when(mockCanAsk.call(any)).thenAnswer((_) async {
          return Right(false);
        });

        bloc.confirmRequest(false);

        await expectLater(
          bloc.stream,
          emitsInOrder([
            PermissionBlocRequesting(
              permission: tPermission,
            ),
            PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.denied,
            ),
          ]),
        );
      });

      test('RequireConfirm->ConfirmSuccess->PermissionDenied', () async {
        bloc.emit(PermissionBlocRequestConfirm(
          permission: Permission.contacts,
        ));

        when(mockUpdateCanAsk.call(any)).thenAnswer((_) async {
          return Right(true);
        });
        when(mockCanAsk.call(any)).thenAnswer((_) async {
          return Right(true);
        });
        when(mockRequest.call(any)).thenAnswer((_) async {
          return Right(PermissionStatus.denied);
        });

        bloc.confirmRequest(true);

        await expectLater(
          bloc.stream,
          emitsInOrder([
            PermissionBlocRequesting(
              permission: tPermission,
            ),
            PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.denied,
            ),
          ]),
        );
      });

      test('RequireConfirm->ConfirmSuccess->PermissionGranted', () async {
        bloc.emit(PermissionBlocRequestConfirm(
          permission: Permission.contacts,
        ));

        when(mockUpdateCanAsk.call(any)).thenAnswer((_) async {
          return Right(true);
        });
        when(mockCanAsk.call(any)).thenAnswer((_) async {
          return Right(true);
        });
        when(mockRequest.call(any)).thenAnswer((_) async {
          return Right(PermissionStatus.granted);
        });

        bloc.confirmRequest(true);

        await expectLater(
          bloc.stream,
          emitsInOrder([
            PermissionBlocRequesting(
              permission: tPermission,
            ),
            PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.granted,
            ),
          ]),
        );
      });
    });
  });
}
