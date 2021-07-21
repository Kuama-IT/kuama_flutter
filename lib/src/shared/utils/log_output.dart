import 'dart:developer' as d;
import 'dart:io';

import 'package:kuama_flutter/src/_utils/lg.dart';
import 'package:kuama_flutter/src/shared/utils/debuggable.dart';
import 'package:kuama_flutter/src/shared/utils/logger.dart';
import 'package:kuama_flutter/src/shared/utils/pretty_formatter.dart';

abstract class DebugInfoCollector {
  Map<String, dynamic> collect(Log log) {
    return {
      ...collectMessage(log, log.message),
      if (log.error != null && log.stackTrace != null)
        ...collectErrorAndStackTrace(log, log.error!, log.stackTrace!),
    };
  }

  Map<String, dynamic> collectMessage(Log log, Object m);

  Map<String, dynamic> collectErrorAndStackTrace(Log log, Object e, StackTrace st) {
    return {
      ...(e is Debuggable ? e.collectDebugInfo() : {'Log#Error': e}),
      'Log#StackTrace': st,
    };
  }
}

class JsonDebugInfoCollector extends DebugInfoCollector {
  @override
  Map<String, dynamic> collectMessage(Log log, Object m) {
    return {
      'Log#${log.index}':
          'LogLevel#${log.level.fullName} LogDate#${log.createdAt} LogName#${log.name}',
      ...(m is Debuggable ? m.collectDebugInfo() : {'Log#Message': m}),
    };
  }
}

class PrettyDebugInfoCollector extends DebugInfoCollector {
  @override
  Map<String, dynamic> collectMessage(Log log, Object m) {
    return m is Debuggable ? m.collectDebugInfo() : {'@Log#${log.index}': m};
  }
}

abstract class LogOutput {
  Future<void> write(Log log, Map<String, dynamic> info);
}

class FileLogOutput extends LogOutput {
  final File file;

  FileLogOutput(this.file);

  @override
  Future<void> write(Log log, Map<String, dynamic> info) async {
    final json = prettyJson.convert(info);

    await file.writeAsString(json, mode: FileMode.writeOnlyAppend, flush: true);
    await file.writeAsString(', ', mode: FileMode.writeOnlyAppend, flush: true);
  }
}

class ConsoleLogOutput extends LogOutput {
  @override
  Future<void> write(Log log, Map<String, dynamic> info) async {
    final levelName = log.level.name;

    PrettyFormatter.i.convertInLines(info).forEach((line) {
      d.log(line, name: levelName);
    });
  }
}
