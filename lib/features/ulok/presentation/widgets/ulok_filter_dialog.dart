import 'package:flutter/material.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_filter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class UlokFilterDialog extends StatefulWidget {
  final UlokFilter initialFilter;
  const UlokFilterDialog({super.key, required this.initialFilter});

  @override
  State<UlokFilterDialog> createState() => _UlokFilterDialogState();
}

class _UlokFilterDialogState extends State<UlokFilterDialog> {
  String? _selectedStatus;
  DateTime? _selectedMonthYear;

  final List<String> _statuses = ['OK', 'NOK', 'In Progress'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialFilter.status;
    if (widget.initialFilter.year != null && widget.initialFilter.month != null) {
      _selectedMonthYear = DateTime(widget.initialFilter.year!, widget.initialFilter.month!);
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedMonthYear = null;
    });
  }

  void _applyFilters() {
    final newFilter = UlokFilter(
      status: _selectedStatus,
      month: _selectedMonthYear?.month,
      year: _selectedMonthYear?.year,
    );
    Navigator.pop(context, newFilter);
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedStatus != null) count++;
    if (_selectedMonthYear != null) count++;
    return count;
  }

  Future<void> _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonthYear ?? now,
      firstDate: DateTime(now.year - 10, 1),
      lastDate: DateTime(now.year + 1, 12),
    );
    if (picked != null) {
      setState(() => _selectedMonthYear = DateTime(picked.year, picked.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 20.0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
            ),

            // header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Reset', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            // content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  const SizedBox(height: 4),
                  Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statuses.map((status) {
                      final isSelected = _selectedStatus == status;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedStatus = null;
                            } else {
                              _selectedStatus = status;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor.withOpacity(0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isSelected ? AppColors.primaryColor : Colors.grey[800],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),
                  Divider(color: Colors.grey[300], thickness: 1),
                  const SizedBox(height: 16),

                  // Date Range label
                  Text('Date Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 10),

                  // ROW approach: container shrinks automatically when clear button present
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // main date box - will take the remaining width
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickMonth(context),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[50],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    _selectedMonthYear == null
                                        ? 'Pilih bulan'
                                        : '${_monthName(_selectedMonthYear!.month)} ${_selectedMonthYear!.year}',
                                    style: TextStyle(
                                      color: _selectedMonthYear == null ? Colors.grey[600] : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Icon(Icons.calendar_month, color: AppColors.primaryColor),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // if a date is selected, add gap + clear button so main box shrinks
                      if (_selectedMonthYear != null) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => setState(() => _selectedMonthYear = null),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0,1))],
                            ),
                            child: Icon(Icons.close, size: 18, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // bottom actions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: BorderSide(color: AppColors.primaryColor),
                        foregroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Apply Filters${_activeFiltersCount > 0 ? ' ($_activeFiltersCount)' : ''}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return names[month - 1];
  }
}
