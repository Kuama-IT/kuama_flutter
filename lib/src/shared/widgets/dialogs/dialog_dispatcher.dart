import 'dart:async';

import 'package:flutter/material.dart';

class _DialogEntry<T> {
  final int priority;
  final bool barrierDismissible;
  final WidgetBuilder builder;
  final Completer<T?> done;

  const _DialogEntry({
    this.priority = 0,
    required this.barrierDismissible,
    required this.builder,
    required this.done,
  });
}

class DialogDispatcher extends StatefulWidget {
  final Widget child;

  const DialogDispatcher({Key? key, required this.child}) : super(key: key);

  @override
  DialogDispatcherState createState() => DialogDispatcherState();

  static DialogDispatcherState of(BuildContext context) {
    return context.findAncestorStateOfType<DialogDispatcherState>()!;
  }
}

class DialogDispatcherState extends State<DialogDispatcher> {
  final _dialogs = <String, _DialogEntry>{};
  String? _current;

  bool contains(String name) {
    return _dialogs.containsKey(name);
  }

  Future<T?> show<T>({
    required String name,
    int priority = 0,
    bool barrierDismissible = true,
    required WidgetBuilder builder,
  }) {
    assert(!_dialogs.containsKey(name), 'Dialog "$name" already in queue');
    final entry = _DialogEntry<T>(
      done: Completer(),
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
    if (_dialogs.isEmpty) {
      _show(name, entry);
    } else {
      final current = _findNext();
      if (_current != current) {
        _hide(_current!);
        _show(current, entry);
      }
    }
    _dialogs[name] = entry;
    return entry.done.future;
  }

  void hide(String name, [dynamic result]) {
    _hide(name);
    final entry = _dialogs[name];
    if (entry != null) {
      _dialogs.remove(name);
      entry.done.complete(result);
      _showNext();
    }
  }

  String _findNext() {
    final entries = _dialogs.entries.toList()
      ..sort((a, b) => a.value.priority.compareTo(b.value.priority) * -1);
    return entries.first.key;
  }

  void _showNext() {
    if (_dialogs.isEmpty) return;
    final name = _findNext();
    _show(name, _dialogs[name]!);
  }

  void _show<T>(String name, _DialogEntry<T> entry) {
    _current = name;
    showDialog<T>(
      context: context,
      routeSettings: RouteSettings(name: name),
      barrierDismissible: entry.barrierDismissible,
      builder: entry.builder,
    ).whenComplete(() {
      _dialogs.remove(name);
      _current = null;
      _showNext();
    }).then(entry.done.complete);
  }

  void _hide(String name) {
    Navigator.popUntil(context, (route) => route.settings.name == name);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
