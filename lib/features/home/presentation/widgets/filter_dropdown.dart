import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';

class FilterDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String hintText;
  final VoidCallback? onClear;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.onClear,
  });

  @override
  State<FilterDropdown<T>> createState() => _FilterDropdownState<T>();
}

class _FilterDropdownState<T> extends State<FilterDropdown<T>> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final bool showClearButton = widget.value != null && widget.onClear != null;
    final iconColor = Colors.grey.shade700;
    const animationDuration = Duration(milliseconds: 250);
    const animationCurve = Curves.easeInOut;

    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,
            hint: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.hintText,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            items:
                widget.items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item.value,
                    onTap: item.onTap,
                    alignment: AlignmentDirectional.centerStart,
                    child: item.child,
                  );
                }).toList(),
            value: widget.value,
            onChanged: widget.onChanged,
            onMenuStateChange: (isOpen) {
              setState(() {
                _isOpen = isOpen;
              });
            },
            iconStyleData: IconStyleData(
              icon: SizedBox(
                width: 50,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedAlign(
                      alignment:
                          showClearButton
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      duration: animationDuration,
                      curve: animationCurve,
                      child: AnimatedRotation(
                        turns: _isOpen ? 0.5 : 0,
                        duration: animationDuration,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 24,
                          color: iconColor,
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: animationDuration,
                      curve: animationCurve,
                      right: showClearButton ? 0.0 : -32.0,
                      child: AnimatedSwitcher(
                        duration: animationDuration,
                        transitionBuilder:
                            (child, animation) => FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                        child:
                            showClearButton
                                ? GestureDetector(
                                  key: const ValueKey('clear_icon_gesture'),
                                  onTap: widget.onClear,
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: 32,
                                    height: 48,
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: iconColor,
                                    ),
                                  ),
                                )
                                : const SizedBox(key: ValueKey('empty_space')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            selectedItemBuilder: (context) {
              return widget.items.map((item) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    (item.child as Text).data!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList();
            },
            buttonStyleData: ButtonStyleData(
              height: 50,
              padding: const EdgeInsets.only(left: 14.0, right: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                color: AppColors.cardColor,
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              width: constraints.maxWidth,
              maxHeight: 160,
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.cardColor,
              ),
              offset: const Offset(0, -1),
              isOverButton: false,
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all(6),
                thumbVisibility: MaterialStateProperty.all(true),
                crossAxisMargin: 5,
                mainAxisMargin: 12,
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              selectedMenuItemBuilder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: child,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
