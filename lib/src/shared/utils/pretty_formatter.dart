import 'dart:convert';

class PrettyFormatter {
  static const bottomRight = '╔';
  static const dVertical = '║';
  static const verticalLeft = '╠';
  static const topRight = '╚';
  static const horizontal = '═';

  static const vertical = '|';

  final width = 100;

  static PrettyFormatter instance = PrettyFormatter();
  static PrettyFormatter get i => instance;

  PrettyFormatter();

  void show(Map<String, Object> logs) {
    final lines = convertInLines(logs);
    // ignore: avoid_print
    lines.forEach(print);
  }

  String convertInSheet(Map<String, Object?> logs) {
    return convertInLines(logs).join('\n');
  }

  List<String> convertInLines(Map<String, Object?> logs) {
    final sheet = <String>[];
    if (logs.isEmpty) return sheet;

    final logEntries = logs.entries.toList();

    for (var i = 0; i < logEntries.length; i++) {
      final name = logEntries[i].key;
      final data = logEntries[i].value;
      if (i == 0) {
        sheet.add(_prettyEdge(bottomRight, name));
      } else {
        sheet.add(_prettyEdge(verticalLeft, name));
      }
      sheet.addAll(_prettySplit(name.startsWith('@') ? vertical : dVertical, data));
    }
    sheet.add(_prettyEdge(topRight));

    return sheet;
  }

  String _prettyEdge(String prefix, [String? name]) {
    if (name == null) {
      name = '';
    } else {
      name = ' $name ';
    }
    final missingWidth = width - 1 - 5 - name.length;
    return '${prefix}${horizontal * 5}${name}${horizontal * missingWidth}';
  }

  Iterable<String> _prettySplit(String prefix, Object? data) {
    return _split(data).map((line) => '$prefix $line');
  }

  Iterable<String> _split(Object? data) {
    if (data is Map) {
      return _splitMap(data);
    } else {
      final str = '$data';
      return str.split('\n');
    }
  }

  final _mapEncoder = JsonEncoder.withIndent(' ', (o) => '$o');
  Iterable<String> _splitMap(Map<dynamic, dynamic> map) {
    final lines = _mapEncoder.convert(map).split('\n');
    if (lines.length <= 2) return const <String>[];
    return lines.sublist(1, lines.length - 1);
  }
}
