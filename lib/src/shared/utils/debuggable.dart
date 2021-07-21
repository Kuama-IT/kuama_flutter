import 'package:kuama_flutter/src/_utils/lg.dart';

abstract class Debuggable {
  factory Debuggable(Map<String, dynamic> messages) = _DebugInfo;

  Map<String, dynamic> collectDebugInfo();

  @override
  String toString() => prettyJson.convert(collectDebugInfo());
}

class _DebugInfo with Debuggable {
  final Map<String, dynamic> info;

  _DebugInfo(this.info);

  @override
  Map<String, dynamic> collectDebugInfo() => info;
}
