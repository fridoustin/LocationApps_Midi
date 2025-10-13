import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/wilayah/domain/entities/wilayah.dart';

class SearchableDropdown extends ConsumerWidget {
  final String label;
  final bool isEnabled;
  final WilayahEntity? selectedValue;
  final FutureProvider<List<WilayahEntity>> itemsProvider;
  final ValueChanged<WilayahEntity?> onChanged;
  final bool isRequired;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.itemsProvider,
    required this.onChanged,
    this.selectedValue,
    this.isEnabled = true,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(text: label),
                if (isRequired)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          DropdownSearch<WilayahEntity>(
            enabled: isEnabled,
            items: (String? filter, dynamic infiniteScrollProps) async {
              final list = await ref.read(itemsProvider.future);
              if (filter == null || filter.isEmpty) return list;
              return list.where((w) => w.name.toLowerCase().contains(filter.toLowerCase())).toList();
            },
            itemAsString: (u) => u.name,
            selectedItem: selectedValue,
            onChanged: onChanged,
            compareFn: (item, selectedItem) {
              return item.id == selectedItem.id;
            },

            popupProps: PopupProps.modalBottomSheet(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Cari $label',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              modalBottomSheetProps: const ModalBottomSheetProps(
                backgroundColor: AppColors.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                    child: Text('Pilih $label',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ),
            ),

            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                hintText: selectedValue?.name ?? 'Pilih $label',
                hintStyle: TextStyle(
                  color: AppColors.black.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: isEnabled ? Colors.grey[100] : Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            validator: (value) {
              if (isRequired && value == null) {
                return '$label harus dipilih';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}