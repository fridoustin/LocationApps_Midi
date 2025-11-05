// lib/features/lokasi/presentation/pages/progress_kplt_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/domain/entities/progress_kplt.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';

class ProgressKpltDetailPage extends ConsumerStatefulWidget {
  final ProgressKplt progress;

  const ProgressKpltDetailPage({
    super.key,
    required this.progress,
  });

  @override
  ConsumerState<ProgressKpltDetailPage> createState() => _ProgressKpltDetailPageState();
}

class _ProgressKpltDetailPageState extends ConsumerState<ProgressKpltDetailPage> {
  String? _selectedStep;

  @override
  Widget build(BuildContext context) {
    final completionAsync = ref.watch(completionStatusProvider(widget.progress.id));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detail Progress KPLT'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: completionAsync.when(
        data: (completionData) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card - Dago Atas
                _buildHeaderCard(),

                const SizedBox(height: 24),

                // Timeline Progress KPLT
                _buildTimelineSection(completionData),

                const SizedBox(height: 24),

                // Detail Card - Show selected step or current active
                _buildDetailCard(completionData),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(completionStatusProvider(widget.progress.id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.progress.kpltNama ?? 'Nama KPLT',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Provinsi', widget.progress.kpltProvinsi ?? '-', 
                        'Kabupaten/Kota', widget.progress.kpltKabupaten ?? '-'),
          const SizedBox(height: 12),
          _buildInfoRow('Kecamatan', widget.progress.kpltKecamatan ?? '-',
                        'Kelurahan/Desa', widget.progress.kpltKelurahan ?? '-'),
          const SizedBox(height: 12),
          _buildSingleInfoRow('Alamat', widget.progress.kpltAlamat ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(Map<String, dynamic> completionData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline Progress KPLT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildHorizontalTimeline(completionData),
        ],
      ),
    );
  }

  Widget _buildHorizontalTimeline(Map<String, dynamic> completionData) {
    final steps = [
      {'key': 'mou', 'label': 'MOU'},
      {'key': 'izin_tetangga', 'label': 'Ijin\nTetangga'},
      {'key': 'perizinan', 'label': 'Perizinan'},
      {'key': 'notaris', 'label': 'Notaris'},
      {'key': 'renovasi', 'label': 'Renovasi'},
      {'key': 'grand_opening', 'label': 'Grand\nOpening'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isCompleted = completionData[step['key']]?['completed'] == true;
          final isLast = index == steps.length - 1;
          final isSelected = _selectedStep == step['key'];

          return Row(
            children: [
              _buildTimelineNode(
                step['label']!,
                step['key']!,
                isCompleted,
                isSelected,
              ),
              if (!isLast)
                Container(
                  width: 60,
                  height: 3,
                  color: isCompleted ? AppColors.successColor : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTimelineNode(String label, String key, bool isCompleted, bool isSelected) {
    Color color;
    IconData icon;

    if (isCompleted) {
      color = AppColors.successColor;
      icon = Icons.check_circle;
    } else {
      // Check if this is the current active step
      final isActive = _isActiveStep(key);
      color = isActive ? Colors.orange : Colors.grey[300]!;
      icon = isActive ? Icons.pending : Icons.more_horiz;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStep = key;
        });
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: AppColors.primaryColor, width: 2) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isActiveStep(String key) {
    // Logic untuk determine active step based on current progress status
    final currentStatus = widget.progress.status.value;
    
    if (currentStatus == 'not_started') return key == 'mou';
    if (currentStatus == 'mou') return key == 'izin_tetangga' || key == 'perizinan';
    if (currentStatus == 'perizinan') return key == 'notaris';
    if (currentStatus == 'notaris') return key == 'renovasi';
    if (currentStatus == 'renovasi') return key == 'grand_opening';
    
    return false;
  }

  Widget _buildDetailCard(Map<String, dynamic> completionData) {
    final stepKey = _selectedStep ?? _getCurrentActiveStep();
    final stepData = completionData[stepKey];
    final isCompleted = stepData?['completed'] == true;
    final date = stepData?['date'] as String?;

    String title;
    switch (stepKey) {
      case 'mou':
        title = 'MOU';
        break;
      case 'izin_tetangga':
        title = 'Ijin Tetangga';
        break;
      case 'perizinan':
        title = 'Perizinan';
        break;
      case 'notaris':
        title = 'Notaris';
        break;
      case 'renovasi':
        title = 'Renovasi';
        break;
      case 'grand_opening':
        title = 'Grand Opening';
        break;
      default:
        title = 'Progress';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Status
          Row(
            children: [
              Text(
                'Status: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? AppColors.successColor.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCompleted ? 'Done' : 'In Progress',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppColors.successColor : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          
          if (isCompleted && date != null) ...[
            const SizedBox(height: 12),
            _buildDateRow('Mulai', date),
            const SizedBox(height: 8),
            _buildDateRow('Selesai', date),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              'Proses ini sedang dalam pengerjaan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String dateString) {
    final date = DateTime.parse(dateString);
    final formatted = DateFormat('dd MMMM yyyy').format(date.toLocal());
    
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          label = 'Mulai $formatted',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _getCurrentActiveStep() {
    final status = widget.progress.status.value;
    if (status == 'mou') return 'mou';
    if (status == 'perizinan' || status == 'izin_tetangga') return 'perizinan';
    if (status == 'notaris') return 'notaris';
    if (status == 'renovasi') return 'renovasi';
    if (status == 'grand_opening') return 'grand_opening';
    return 'mou';
  }
}