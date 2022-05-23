import 'dart:async';

enum LogLevel { tmp, verbose, debug, info, warn, error, errorFlutter, errorDart, wtf, nothing }

extension LogLevelName on LogLevel {
  static const _names = <LogLevel, String>{
    LogLevel.tmp: 'TMP',
    LogLevel.verbose: 'V',
    LogLevel.debug: 'D',
    LogLevel.info: 'I',
    LogLevel.warn: 'W',
    LogLevel.error: 'E',
    LogLevel.errorFlutter: 'EF',
    LogLevel.errorDart: 'ED',
    LogLevel.wtf: 'WTF',
  };

  static const _fullNames = <LogLevel, String>{
    LogLevel.tmp: 'TEMPORARY',
    LogLevel.verbose: 'VERBOSE',
    LogLevel.debug: 'DEBUG',
    LogLevel.info: 'INFO',
    LogLevel.warn: 'WARN',
    LogLevel.error: 'ERROR',
    LogLevel.errorFlutter: 'ERROR_FLUTTER',
    LogLevel.errorDart: 'ERROR_DART',
    LogLevel.wtf: 'WTF',
  };

  String get fullName => _fullNames[this]!;

  String get name => _names[this]!;
}

class Log {
  final int index;
  final DateTime createdAt;
  final String name;
  final LogLevel level;
  final Object message;
  final Object? error;
  final StackTrace? stackTrace;

  const Log({
    required this.index,
    required this.createdAt,
    required this.name,
    required this.level,
    required this.message,
    required this.error,
    required this.stackTrace,
  });

  @override
  String toString() {
    final b = StringBuffer('$createdAt $level $name\n$message');
    if (error != null) b.writeln('$error\n$stackTrace');
    return b.toString();
  }
}

class Logger {
  static LogLevel level = LogLevel.tmp;

  static final _logSubject = StreamController<Log>.broadcast();

  /// Be careful not to re-enter errors in the logger
  static Stream<Log> get onLog => _logSubject.stream;

  final String name;
  int _index = 0;

  Logger(this.name);

  /// Temporary
  void tmp(Object message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.tmp, message, error, stackTrace);
  }

  /// Verbose
  void v(Object message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.verbose, message, error, stackTrace);
  }

  /// Debug
  void d(Object message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  /// Info
  void i(Object message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  /// Warning
  void w(Object message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warn, message, error, stackTrace);
  }

  /// Generic Error
  void e(Object message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  /// Flutter Error
  void ef(Object message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.errorFlutter, message, error, stackTrace);
  }

  /// Dart Error
  void ed(Object message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.errorDart, message, error, stackTrace);
  }

  /// WTF
  void wtf(Object message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.wtf, message, error, stackTrace);
  }

  void _log(LogLevel level, Object message, Object? error, StackTrace? stackTrace) {
    if (level.index < Logger.level.index) return;

    try {
      if (message is _LogFunction) {
        message = message();
      }

      _logSubject.add(Log(
        index: _index++,
        createdAt: DateTime.now().toUtc(),
        name: name,
        level: level,
        message: message,
        error: error,
        stackTrace: stackTrace ?? (error != null ? StackTrace.current : stackTrace),
      ));
    } catch (error, stackTrace) {
      // ignore: avoid_print
      print(error);
      // ignore: avoid_print
      print(stackTrace);
    }
  }
}

typedef _LogFunction = Object Function();
