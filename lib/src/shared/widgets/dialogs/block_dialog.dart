import 'dart:async';

import 'package:flutter/material.dart';

class BlockDialog extends StatefulWidget {
  final Completer dismissCompleter;

  const BlockDialog({
    Key? key,
    required this.dismissCompleter,
  }) : super(key: key);

  @override
  State<BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<BlockDialog> {
  Future? _future;

  @override
  void initState() {
    super.initState();
    initDismiss();
  }

  @override
  void didUpdateWidget(covariant BlockDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dismissCompleter != oldWidget.dismissCompleter) {
      initDismiss();
    }
  }

  @override
  void dispose() {
    _future == null;
    super.dispose();
  }

  void initDismiss() {
    _future = widget.dismissCompleter.future;
    widget.dismissCompleter.future.whenComplete(() => dismiss(widget.dismissCompleter.future));
  }

  void dismiss(Future future) {
    if (_future != future) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      child: CircularProgressIndicator(),
    );
  }
}
