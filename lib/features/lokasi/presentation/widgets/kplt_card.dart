import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/domain/entities/form_kplt.dart';

class KpltCard extends StatefulWidget {
  final FormKPLT kplt;
  final VoidCallback? onTap;
  
  const KpltCard({
    super.key, 
    required this.kplt,
    this.onTap,
  });

  @override
  State<KpltCard> createState() => _KpltCardState();
}
  
class _KpltCardState extends State<KpltCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper untuk mendapatkan progress percentage
  double _getProgressPercentage() {
    return widget.kplt.progressPercentage ?? 0.0;
  }

  // Helper untuk mendapatkan list progress steps
  List<_ProgressStepData> _getProgressSteps() {
    final currentProgress = _getProgressPercentage();
    
    return [
      _ProgressStepData(
        title: 'KPLT Created',
        date: widget.kplt.tanggal,
        isCompleted: true, 
      ),
      _ProgressStepData(
        title: 'Site Survey',
        date: currentProgress >= 20 ? widget.kplt.tanggal.add(const Duration(days: 2)) : null,
        isCompleted: currentProgress >= 20,
      ),
      _ProgressStepData(
        title: 'Document Collection',
        date: currentProgress >= 30 ? widget.kplt.tanggal.add(const Duration(days: 5)) : null,
        isCompleted: currentProgress >= 30,
      ),
      _ProgressStepData(
        title: 'KPLT Approval',
        date: currentProgress >= 40 ? widget.kplt.tanggal.add(const Duration(days: 7)) : null,
        isCompleted: currentProgress >= 40,
      ),
      _ProgressStepData(
        title: 'MOU Process',
        date: currentProgress >= 50 ? widget.kplt.tanggal.add(const Duration(days: 10)) : null,
        isCompleted: currentProgress >= 50,
      ),
      _ProgressStepData(
        title: 'Notaris Process',
        date: currentProgress >= 60 ? widget.kplt.tanggal.add(const Duration(days: 15)) : null,
        isCompleted: currentProgress >= 60,
      ),
      _ProgressStepData(
        title: 'Perizinan',
        date: currentProgress >= 70 ? widget.kplt.tanggal.add(const Duration(days: 20)) : null,
        isCompleted: currentProgress >= 70,
      ),
      _ProgressStepData(
        title: 'Renovasi',
        date: currentProgress >= 80 ? widget.kplt.tanggal.add(const Duration(days: 30)) : null,
        isCompleted: currentProgress >= 80,
      ),
      _ProgressStepData(
        title: 'Grand Opening',
        date: currentProgress >= 90 ? widget.kplt.tanggal.add(const Duration(days: 45)) : null,
        isCompleted: currentProgress >= 90,
      ),
    ];
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fullAddress = '${widget.kplt.alamat}, Kec. ${widget.kplt.kecamatan}, ${widget.kplt.kabupaten}, ${widget.kplt.provinsi}';
    final formattedDate = DateFormat('dd MMMM yyyy').format(widget.kplt.tanggal);
    final progressPercentage = _getProgressPercentage();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      elevation: 0,
      child: Column(
        children: [
          InkWell(
            onTap: widget.onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Expand Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.kplt.namaLokasi,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _toggleExpanded,
                        child: RotationTransition(
                          turns: _rotationAnimation,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Address with icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          fullAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Date with icon
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Update : $formattedDate',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Bar and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.kplt.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        '${progressPercentage.toInt()}%',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildProgressSteps(),
            crossFadeState: _isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSteps() {
    final steps = _getProgressSteps();
    
    // Filter hanya step yang sudah completed atau step berikutnya yang sedang in progress
    final displayedSteps = <_ProgressStepData>[];
    bool foundInProgress = false;
    
    for (var step in steps) {
      if (step.isCompleted) {
        displayedSteps.add(step);
      } else if (!foundInProgress) {
        displayedSteps.add(step);
        foundInProgress = true;
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey[300], thickness: 1),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.list_alt, size: 20, color: AppColors.secondaryColor),
              SizedBox(width: 8),
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(displayedSteps.length, (index) {
            final step = displayedSteps[index];
            final isLast = index == displayedSteps.length - 1;
            return _buildProgressStepItem(step, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildProgressStepItem(_ProgressStepData step, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted 
                        ? AppColors.successColor 
                        : Colors.transparent,
                    border: Border.all(
                      color: step.isCompleted 
                          ? AppColors.successColor 
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: step.isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Date info (only for completed)
                  if (step.isCompleted && step.date != null)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.successColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Selesai: ${DateFormat('dd MMM yyyy, HH:mm').format(step.date!.toLocal())}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.pending_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Dalam Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStepData {
  final String title;
  final DateTime? date;
  final bool isCompleted;

  _ProgressStepData({
    required this.title,
    this.date,
    required this.isCompleted,
  });
}