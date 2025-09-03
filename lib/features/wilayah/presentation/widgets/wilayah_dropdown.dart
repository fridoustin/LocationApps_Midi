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

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.itemsProvider,
    required this.onChanged,
    this.selectedValue,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownSearch<WilayahEntity>(
        enabled: isEnabled,

        items: (String? filter, dynamic infiniteScrollProps) async {
          final list = await ref.read(itemsProvider.future);
          if (filter == null || filter.isEmpty) return list;
          return list.where((w) => w.name.toLowerCase().contains(filter.toLowerCase())).toList();
        },

        itemAsString: (u) => u.name,
        selectedItem: selectedValue,
        onChanged: onChanged,

        compareFn: (item, selectedItem) => item.id == selectedItem.id,

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
            child: Center(child: Text('Pilih $label', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
        ),

        // v7: nama properti berubah jadi decoratorProps
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: isEnabled ? Colors.grey[100] : Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),

        validator: (value) => value == null ? '$label harus dipilih' : null,
      ),
    );
  }
}
