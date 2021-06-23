import 'dart:async';
import 'dart:developer' as d;

import 'package:kuama_flutter/src/shared/utils/pretty_formatter.dart';
import 'package:logging/logging.dart';

StreamSubscription listenLogger() {
  return Logger.root.onRecord.listen((record) {
    final levelName = record.level.name;
    final object = record.object;
    final error = record.error;
    final stackTrace = record.stackTrace;

    if (object is PrettyObject) {
      PrettyFormatter.i.convertInLines({
        ...object.toPrettyMap(),
        if (error != null) 'Error: ${error.runtimeType}': '$error\n$stackTrace'
      }).forEach((line) {
        d.log(line, name: levelName);
      });
      return;
    }

    d.log(record.message, name: levelName, error: error, stackTrace: stackTrace);
  });
}
