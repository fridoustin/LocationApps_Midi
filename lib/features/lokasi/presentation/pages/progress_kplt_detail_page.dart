// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/progress_kplt.dart';
import 'package:midi_location/features/lokasi/presentation/pages/mou_detail_page.dart';
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

  String _formatDateSafe(String? dateStr) {
  if (dateStr == null) return '-';
  final dt = DateTime.tryParse(dateStr);
  if (dt == null) return '-';
  return DateFormat('dd MMMM yyyy').format(dt.toLocal());
}

  @override
  Widget build(BuildContext context) {
    final completionAsync = ref.watch(completionStatusProvider(widget.progress.id));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Detail Progress KPLT',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: completionAsync.when(
        data: (completionData) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card - Modern Style
                _buildHeaderCard(),

                const SizedBox(height: 16),

                // Location Info Card
                _buildLocationCard(),

                const SizedBox(height: 16),

                // Timeline Progress Card
                _buildTimelineCard(completionData),

                const SizedBox(height: 16),

                // Detail Card - Show selected step or current active
                _buildDetailCard(completionData),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$err',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(completionStatusProvider(widget.progress.id)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.store,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.progress.kpltNama ?? 'Nama KPLT',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.progress.status.value).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusLabel(widget.progress.status.value),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(widget.progress.status.value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                "assets/icons/location.svg",
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              const Text(
                'Lokasi KPLT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationRow('Provinsi', widget.progress.kpltProvinsi ?? '-'),
          const SizedBox(height: 12),
          _buildLocationRow('Kabupaten/Kota', widget.progress.kpltKabupaten ?? '-'),
          const SizedBox(height: 12),
          _buildLocationRow('Kecamatan', widget.progress.kpltKecamatan ?? '-'),
          const SizedBox(height: 12),
          _buildLocationRow('Kelurahan/Desa', widget.progress.kpltKelurahan ?? '-'),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.place_outlined, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat Lengkap',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.progress.kpltAlamat ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> completionData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Timeline Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildHorizontalTimeline(completionData),
        ],
      ),
    );
  }

  Widget _buildHorizontalTimeline(Map<String, dynamic> completionData) {
    final steps = [
      {'key': 'mou', 'label': 'MOU', 'icon': Icons.handshake},
      {'key': 'izin_tetangga', 'label': 'Izin\nTetangga', 'icon': Icons.people},
      {'key': 'perizinan', 'label': 'Perizinan', 'icon': Icons.description},
      {'key': 'notaris', 'label': 'Notaris', 'icon': Icons.account_balance},
      {'key': 'renovasi', 'label': 'Renovasi', 'icon': Icons.construction},
      {'key': 'grand_opening', 'label': 'Grand\nOpening', 'icon': Icons.celebration},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final stepKey = step['key'] as String;
          final stepLabel = step['label'] as String;
          final stepIcon = step['icon'] as IconData;
          final isCompleted = completionData[stepKey]?['completed'] == true;
          final isLast = index == steps.length - 1;
          final isSelected = _selectedStep == stepKey;

          return Row(
            children: [
              _buildTimelineNode(
                stepLabel,
                stepKey,
                stepIcon,
                isCompleted,
                isSelected,
              ),
              if (!isLast)
                Container(
                  width: 50,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 45),
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? LinearGradient(
                            colors: [
                              AppColors.successColor,
                              AppColors.successColor.withOpacity(0.7),
                            ],
                          )
                        : null,
                    color: isCompleted ? null : Colors.grey[300],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTimelineNode(String label, String key, IconData iconData, bool isCompleted, bool isSelected) {
    final isActive = _isActiveStep(key);
    
    Color backgroundColor;
    Color iconColor;
    IconData displayIcon;

    if (isCompleted) {
      backgroundColor = AppColors.successColor;
      iconColor = Colors.white;
      displayIcon = Icons.check_circle;
    } else if (isActive) {
      backgroundColor = Colors.orange;
      iconColor = Colors.white;
      displayIcon = iconData;
    } else {
      backgroundColor = Colors.grey[300]!;
      iconColor = Colors.grey[600]!;
      displayIcon = iconData;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStep = (_selectedStep == key) ? null : key;
        });
      },
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: AppColors.primaryColor, width: 1)
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                displayIcon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.primaryColor : Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isActiveStep(String key) {
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
    final isActive = _isActiveStep(stepKey);
    final completedDate = stepData?['date'] as String?;
    final createdDate = stepData?['created_date'] as String?;

    String title;
    String description;
    IconData stepIcon;
    
    switch (stepKey) {
      case 'mou':
        title = 'MOU';
        description = 'Tahap pembuatan dan penandatanganan kesepakatan awal';
        stepIcon = Icons.handshake;
        break;
      case 'izin_tetangga':
        title = 'Izin Tetangga';
        description = 'Proses mendapatkan persetujuan dari tetangga sekitar';
        stepIcon = Icons.people;
        break;
      case 'perizinan':
        title = 'Perizinan';
        description = 'Pengurusan dokumen dan izin resmi dari instansi terkait';
        stepIcon = Icons.description;
        break;
      case 'notaris':
        title = 'Notaris';
        description = 'Proses legalisasi dokumen melalui notaris';
        stepIcon = Icons.account_balance;
        break;
      case 'renovasi':
        title = 'Renovasi';
        description = 'Tahap perbaikan dan penataan lokasi';
        stepIcon = Icons.construction;
        break;
      case 'grand_opening':
        title = 'Grand Opening';
        description = 'Peresmian dan pembukaan lokasi';
        stepIcon = Icons.celebration;
        break;
      default:
        title = 'Progress';
        description = 'Detail tahapan progress';
        stepIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? AppColors.successColor.withOpacity(0.15)
                      : isActive
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  stepIcon,
                  color: isCompleted 
                      ? AppColors.successColor 
                      : isActive
                          ? Colors.orange
                          : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCompleted 
                    ? [AppColors.successColor.withOpacity(0.1), AppColors.successColor.withOpacity(0.05)]
                    : isActive
                        ? [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)]
                        : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted 
                    ? AppColors.successColor.withOpacity(0.3)
                    : isActive
                        ? Colors.orange.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted 
                      ? Icons.check_circle 
                      : isActive
                          ? Icons.schedule
                          : Icons.lock_outline,
                  size: 20,
                  color: isCompleted 
                      ? AppColors.successColor 
                      : isActive
                          ? Colors.orange
                          : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  isCompleted 
                      ? 'Selesai' 
                      : isActive
                          ? 'Dalam Pengerjaan'
                          : 'Belum Dimulai',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCompleted 
                        ? AppColors.successColor 
                        : isActive
                            ? Colors.orange
                            : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          if (isCompleted && completedDate != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Tanggal Mulai',
                    value: _formatDateSafe(createdDate),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.event_available,
                    label: 'Tanggal Selesai',
                    value: _formatDateSafe(completedDate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildViewDetailButton(context, stepKey),
          ] else if (isActive) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tahapan ini sedang dalam proses pengerjaan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tahapan ini belum dapat dimulai. Selesaikan tahapan sebelumnya terlebih dahulu.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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

  String _getCurrentActiveStep() {
    final status = widget.progress.status.value;
    if (status == 'mou') return 'mou';
    if (status == 'perizinan' || status == 'izin_tetangga') return 'perizinan';
    if (status == 'notaris') return 'notaris';
    if (status == 'renovasi') return 'renovasi';
    if (status == 'grand_opening') return 'grand_opening';
    return 'mou';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'grand_opening':
        return AppColors.successColor;
      case 'in_progress':
      case 'mou':
      case 'perizinan':
      case 'notaris':
      case 'renovasi':
        return Colors.orange;
      case 'not_started':
        return Colors.grey;
      default:
        return AppColors.primaryColor;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return 'Selesai';
      case 'in_progress':
        return 'Dalam Progress';
      case 'mou':
        return 'Tahap MOU';
      case 'perizinan':
        return 'Tahap Perizinan';
      case 'notaris':
        return 'Tahap Notaris';
      case 'renovasi':
        return 'Tahap Renovasi';
      case 'grand_opening':
        return 'Grand Opening';
      case 'not_started':
        return 'Belum Dimulai';
      default:
        return status;
    }
  }

  Widget _buildViewDetailButton(BuildContext context, String stepKey) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToStepDetail(context, stepKey),
        icon: const Icon(Icons.visibility, size: 20),
        label: const Text('Lihat Detail'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _navigateToStepDetail(BuildContext context, String stepKey) {
    switch (stepKey) {
      case 'mou':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MouDetailPage(
              progressKpltId: widget.progress.id,
              kpltName: widget.progress.kpltNama ?? 'KPLT',
            ),
          ),
        );
        break;
      case 'izin_tetangga':
        // TODO: Navigate to Izin Tetangga detail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Izin Tetangga belum tersedia')),
        );
        break;
      case 'perizinan':
        // TODO: Navigate to Perizinan detail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Perizinan belum tersedia')),
        );
        break;
      case 'notaris':
        // TODO: Navigate to Notaris detail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Notaris belum tersedia')),
        );
        break;
      case 'renovasi':
        // TODO: Navigate to Renovasi detail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Renovasi belum tersedia')),
        );
        break;
      case 'grand_opening':
        // TODO: Navigate to Grand Opening detail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Grand Opening belum tersedia')),
        );
        break;
    }
  }
}