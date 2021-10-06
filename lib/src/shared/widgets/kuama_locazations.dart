import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failures/dart_failures.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failures/flutter_failures.dart';

class _KuamaLocalizationsDelegate extends LocalizationsDelegate<KuamaLocalizations> {
  const _KuamaLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<KuamaLocalizations> load(Locale locale) => SynchronousFuture(const KuamaLocalizations());

  @override
  bool shouldReload(covariant LocalizationsDelegate<KuamaLocalizations> old) => false;
}

class KuamaLocalizations {
  static const _KuamaLocalizationsDelegate delegate = _KuamaLocalizationsDelegate();

  const KuamaLocalizations();

  String translateFailure(Failure failure) {
    Material;
    if (failure is HttpClientFailure) {
      return onTranslateHttpClientFailure(failure);
    } else if (failure is PlatformFailure) {
      return onTranslatePlatformFailure(failure);
    }
    return onTranslateUnhandledFailure(failure);
  }

  String onTranslateHttpClientFailure(HttpClientFailure failure) {
    return 'Server error (${failure.dioError.response?.statusCode ?? '---'})';
  }

  String onTranslatePlatformFailure(PlatformFailure failure) {
    return 'Platform crashed';
  }

  String onTranslateUnhandledFailure(Failure failure) {
    return 'App crashed';
  }
}
