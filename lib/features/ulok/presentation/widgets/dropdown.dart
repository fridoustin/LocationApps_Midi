import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';

class PopupButtonForm extends ConsumerWidget {
  final String label;
  final FutureProvider<List<String>> optionsProvider;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;
  final bool isRequired;

  const PopupButtonForm({
    super.key,
    required this.label,
    required this.optionsProvider,
    this.selectedValue,
    required this.onSelected,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(optionsProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              children: [
                TextSpan(text: label),
                if (isRequired)
                  const TextSpan(
                      text: " *",
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FormField<String>(
            validator: (value) {
              if (isRequired && selectedValue == null) {
                return '$label harus dipilih';
              }
              return null;
            },
            builder: (FormFieldState<String> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  optionsAsync.when(
                    data: (items) => _buildButton(context, items),
                    loading: () => _buildLoadingState(),
                    error: (err, stack) => _buildErrorState(),
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 5.0),
                      child: Text(
                        state.errorText!,
                        style: const TextStyle(
                            color: AppColors.errorColor, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, List<String> items) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                selectedValue ?? 'Pilih opsi',
                style: TextStyle(
                    color: selectedValue == null
                        ? AppColors.black.withOpacity(0.5)
                        : AppColors.black),
              ),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: Colors.white, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
            child: PopupMenuButton<String>(
              icon: SvgPicture.asset("assets/icons/down_arrow.svg",
                  width: 10, height: 10),
              onSelected: onSelected,
              itemBuilder: (BuildContext context) {
                // 2. Bangun item dengan divider
                return items.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk tampilan saat loading
  Widget _buildLoadingState() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }

  // Widget untuk tampilan saat error
  Widget _buildErrorState() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Gagal memuat opsi',
              style: TextStyle(color: AppColors.errorColor))),
    );
  }
}

