# CHANGELOG

## 0.2.2
> 2023-10-19
- fix: `Continue` and `Cancel` button's strings in permission dialog 

## 0.2.1
> 2023-08-11
- feat: update Dio version

## 0.2.0
> 2022-10-18
- feat: customize a OrderActivePositionBlocListener with custom pickers

## 0.1.0
- The package no longer exposes `dartz` but retains tuple support with the `tuple` package, it depends on indirect `quiver` package
- `UseCase` are now simple functions that take a parameter as input and return a result. Catch `Failure` exceptions to handle use case fillings. Do not capture
  if it is not necessary and or you do not want to manage the failure, let the error go on forever.
- Moved `BuildContext.showDialog` and `BuildContext.showGeneralDialog` to `flutter_extensions` package

## 0.0.1

- Now the stream returned by `StreamUseCase` and `ProgressUseCase` is not closed when they receive an error
- `FlutterConsoleLogOutput` has been added to avoid conflicting flutter prints with logger prints
- `DateTimeSerializerPlugin` has been added
- Added `Permission.notification` and `Permission.camera`
