import 'package:flutter/material.dart';

mixin TextFieldControllerMixin {
  String formatNumber(num? number) {
    if (number == null) return '';
    if (number.truncateToDouble() == number) {
      return number.truncate().toString();
    }
    return number.toString();
  }

  void updateControllerIfNeeded(
    TextEditingController controller,
    String newValue,
    bool isUserTyping,
  ) {
    if (!isUserTyping && controller.text != newValue) {
      final selection = controller.selection;
      controller.text = newValue;
      if (selection.start <= newValue.length) {
        controller.selection = selection;
      }
    }
  }

  void handleNumericFieldChange({
    required String value,
    required Function(String) onChanged,
    required Function(bool) setTypingFlag,
    required void Function() triggerRebuild,
  }) {
    setTypingFlag(true);
    onChanged(value);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      setTypingFlag(false);
      triggerRebuild();
    });
  }
}