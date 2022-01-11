import 'package:flutter/material.dart' as w;
import 'package:flutter/material.dart' hide showGeneralDialog, showDialog;

// ==================== DART  ====================

extension BoolHandlers on bool {
  R fold<R>(R Function() ifFalse, R Function() ifTrue) => this ? ifTrue() : ifFalse();

  /// Returns the value if it is true otherwise it returns null.
  R? ifTrue<R>(R result) => this ? result : null;

  /// Returns the value if it is false otherwise it returns null.
  R? ifFalse<R>(R result) => this ? null : result;
}

extension UnwaitedFuture on Future<dynamic> {
  void unawaited() => this;
}

// ==================== FLUTTER  ====================

extension BuildContextKuamaExtension on BuildContext {
  Future<T?> showGeneralDialog<T>({
    required WidgetBuilder builder,
  }) {
    return w.showGeneralDialog(
      context: this,
      pageBuilder: (context, _, __) => builder(context),
    );
  }
}

extension CrossFadeStateOnBool on bool {
  CrossFadeState toCrossFadeState() {
    return this ? CrossFadeState.showSecond : CrossFadeState.showFirst;
  }
}

extension PopUntilInitialNavigator on NavigatorState {
  /// Back to the first page
  Future<void> popUntilFirst() async {
    while (await maybePop()) {}
    assert(!canPop(), 'I was unable to return to the first page');
  }
}
