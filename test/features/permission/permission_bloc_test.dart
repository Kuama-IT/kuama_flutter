import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/permissions.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

class _MockCanAskPermission extends Mock implements CanAskPermission {}

class _MockUpdateCanAskPermission extends Mock implements UpdateCanAskPermission {}

class _MockCheckPermission extends Mock implements CheckPermission {}

class _MockRequestPermission extends Mock implements RequestPermission {}

class _FakeUpdateCanAskPermissionParams extends Fake implements UpdateCanAskPermissionParams {}

void main() {
  late _MockCanAskPermission mockCanAsk;
  late _MockUpdateCanAskPermission mockUpdateCanAsk;
  late _MockCheckPermission mockCheck;
  late _MockRequestPermission mockRequest;

  late PermissionBloc bloc;

  const tPermission = Permission.contacts;

  setUp(() {
    GetIt.instance
      ..reset()
      ..registerSingleton<CanAskPermission>(mockCanAsk = _MockCanAskPermission())
      ..registerSingleton<UpdateCanAskPermission>(mockUpdateCanAsk = _MockUpdateCanAskPermission())
      ..registerSingleton<CheckPermission>(mockCheck = _MockCheckPermission())
      ..registerSingleton<RequestPermission>(mockRequest = _MockRequestPermission());

    fallbackValues
      ..registerEnum(Permission.values)
      ..register(_FakeUpdateCanAskPermissionParams());

    PermissionBloc.isTesting = true;
    bloc = ContactsPermissionBloc();
  });

  group('Test PermissionBloc', () {
    group('Load', () {
      test('Load->ConfirmNegated', () async {
        when(() => mockCanAsk.call(any())).thenAnswer((_) async {
          await Future.delayed(const Duration());
          return false;
        });

        bloc.load();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const PermissionBlocRequesting(
              permission: tPermission,
            ),
            const PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.denied,
            ),
          ]),
        );
      });

      test('Load->PermissionPermanentlyDenied', () async {
        when(() => mockCanAsk.call(any())).thenAnswer((_) async {
          await Future.delayed(const Duration());
          return true;
        });
        when(() => mockCheck.call(any())).thenAnswer((_) async {
          return PermissionStatus.permanentlyDenied;
        });

        bloc.load();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const PermissionBlocRequesting(
              permission: tPermission,
            ),
            const PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.permanentlyDenied,
            ),
          ]),
        );
      });

      test('Load->PermissionDenied', () async {
        when(() => mockCanAsk.call(any())).thenAnswer((_) async {
          await Future.delayed(const Duration());
          return true;
        });
        when(() => mockCheck.call(any())).thenAnswer((_) async {
          return PermissionStatus.denied;
        });

        bloc.load();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const PermissionBlocRequesting(
              permission: tPermission,
            ),
            const PermissionBlocLoaded(
              permission: Permission.contacts,
            ),
          ]),
        );
      });

      test('Load->PermissionGranted', () async {
        when(() => mockCanAsk.call(any())).thenAnswer((_) async {
          await Future.delayed(const Duration());
          return true;
        });
        when(() => mockCheck.call(any())).thenAnswer((_) async {
          return PermissionStatus.granted;
        });

        bloc.load();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const PermissionBlocRequesting(
              permission: tPermission,
            ),
            const PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.granted,
            ),
          ]),
        );
      });
    });

    group('Request', () {
      test('Request->RequireNegated->PermissionDenied', () async {
        when(() => mockCanAsk.call(any())).thenAnswer((_) async {
          await Future.delayed(const Duration());
          return false;
        });

        bloc.request();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const PermissionBlocRequesting(
              permission: tPermission,
            ),
            const PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.denied,
            ),
          ]),
        );
      });

      test('Request->RequireGranted->PermissionDenied', () async {
        when(() => mockCanAsk.call(any())).thenAnswer((_) async {
          return true;
        });
        when(() => mockCheck.call(any())).thenAnswer((_) async {
          return PermissionStatus.denied;
        });

        bloc.request();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const PermissionBlocRequesting(
              permission: tPermission,
            ),
            const PermissionBlocRequestConfirm(
              permission: Permission.contacts,
            ),
          ]),
        );
      });

      test('Request->RequireGranted->PermissionGranted', () async {
        when(() => mockCanAsk.call(any())).thenAnswer((_) async {
          return true;
        });
        when(() => mockCheck.call(any())).thenAnswer((_) async {
          return PermissionStatus.granted;
        });

        bloc.request();

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const PermissionBlocRequesting(
              permission: tPermission,
            ),
            const PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.granted,
            ),
          ]),
        );
      });
    });

    group('ConfirmRequest', () {
      test('RequireConfirm->ConfirmFailed->PermissionDenied', () async {
        bloc.emit(const PermissionBlocRequestConfirm(
          permission: Permission.contacts,
        ));

        when(() => mockUpdateCanAsk.call(any())).thenAnswer((_) async {
          return false;
        });
        when(() => mockCanAsk.call(any())).thenAnswer((_) async {
          return false;
        });

        bloc.confirmRequest(false);

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const PermissionBlocRequesting(
              permission: tPermission,
            ),
            const PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.denied,
            ),
          ]),
        );
      });

      test('RequireConfirm->ConfirmSuccess->PermissionDenied', () async {
        bloc.emit(const PermissionBlocRequestConfirm(
          permission: Permission.contacts,
        ));

        when(() => mockUpdateCanAsk.call(any())).thenAnswer((_) async {
          return true;
        });
        when(() => mockCanAsk.call(any())).thenAnswer((_) async {
          return true;
        });
        when(() => mockRequest.call(any())).thenAnswer((_) async {
          return PermissionStatus.denied;
        });

        bloc.confirmRequest(true);

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const PermissionBlocRequesting(
              permission: tPermission,
            ),
            const PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.denied,
            ),
          ]),
        );
      });

      test('RequireConfirm->ConfirmSuccess->PermissionGranted', () async {
        bloc.emit(const PermissionBlocRequestConfirm(
          permission: Permission.contacts,
        ));

        when(() => mockUpdateCanAsk.call(any())).thenAnswer((_) async {
          return true;
        });
        when(() => mockCanAsk.call(any())).thenAnswer((_) async {
          return true;
        });
        when(() => mockRequest.call(any())).thenAnswer((_) async {
          return PermissionStatus.granted;
        });

        bloc.confirmRequest(true);

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const PermissionBlocRequesting(
              permission: tPermission,
            ),
            const PermissionBlocRequested(
              permission: Permission.contacts,
              status: PermissionStatus.granted,
            ),
          ]),
        );
      });
    });
  });
}
