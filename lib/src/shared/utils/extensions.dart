import 'package:flutter/material.dart' hide showGeneralDialog, showDialog;

// ==================== DART  ====================

extension BoolKuamaExtensions on bool {
  R fold<R>(R Function() ifFalse, R Function() ifTrue) => this ? ifTrue() : ifFalse();

  /// Returns the value if it is true otherwise it returns null.
  R? ifTrue<R>(R result) => this ? result : null;

  /// Returns the value if it is false otherwise it returns null.
  R? ifFalse<R>(R result) => this ? null : result;
}

// ==================== FLUTTER  ====================

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
