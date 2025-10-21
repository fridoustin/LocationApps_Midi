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
    // TODO: Nanti ganti dengan data real dari FormKPLT
    return widget.kplt.progressPercentage ?? 0.0; 
    // switch (widget.kplt.status) {
    //   case 'Need Input': return 0.0;
    //   case 'In Progress': return 10.0;
    //   case 'Waiting for Forum': return 50.0;
    //   case 'OK': return 100.0;
    //   case 'NOK': return 100.0;
    //   default: return 0.0;
    // }
  }

  // Helper untuk mendapatkan list progress steps
  List<_ProgressStepData> _getProgressSteps() {
    // TODO: Nanti ambil dari widget.kplt.progressSteps
    // return widget.kplt.progressSteps ?? [];
    
    final currentProgress = _getProgressPercentage();
    
    // Dummy data - nanti ganti dengan data real dari database
    return [
      _ProgressStepData(
        title: 'KPLT Created',
        date: widget.kplt.tanggal,
        isCompleted: currentProgress >= 10,
        percentage: 10,
      ),
      _ProgressStepData(
        title: 'Site Survey',
        date: currentProgress >= 20 ? widget.kplt.tanggal.add(const Duration(days: 2)) : null,
        isCompleted: currentProgress >= 20,
        percentage: 20,
      ),
      _ProgressStepData(
        title: 'Document Collection',
        date: currentProgress >= 30 ? widget.kplt.tanggal.add(const Duration(days: 5)) : null,
        isCompleted: currentProgress >= 30,
        percentage: 30,
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
                'Progress Timeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
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
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted ? AppColors.secondaryColor : Colors.transparent,
                    border: Border.all(
                      color: step.isCompleted ? AppColors.secondaryColor : Colors.grey[400]!,
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
                      color: step.isCompleted ? AppColors.secondaryColor : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: step.isCompleted ? Colors.black87 : Colors.grey[600],
                          ),
                        ),
                        if (step.date != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(step.date!),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: step.isCompleted 
                          ? AppColors.secondaryColor.withOpacity(0.15) 
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${step.percentage}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: step.isCompleted ? AppColors.secondaryColor : Colors.grey[600],
                      ),
                    ),
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
  final int percentage;

  _ProgressStepData({
    required this.title,
    this.date,
    required this.isCompleted,
    required this.percentage,
  });
}