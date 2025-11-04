import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/domain/entities/progress_kplt.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_progress_provider.dart';

class ProgressKpltCard extends ConsumerStatefulWidget {
  final ProgressKplt progress;
  final VoidCallback? onTap;
  
  const ProgressKpltCard({
    super.key,
    required this.progress,
    this.onTap,
  });

  @override
  ConsumerState<ProgressKpltCard> createState() => _ProgressKpltCardState();
}

class _ProgressKpltCardState extends ConsumerState<ProgressKpltCard>
    with SingleTickerProviderStateMixin {
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

  Color _getStatusColor() {
    if (widget.progress.isCompleted) {
      return AppColors.successColor;
    } else if (widget.progress.progressPercentage > 0) {
      return AppColors.secondaryColor;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = widget.progress.updatedAt != null
        ? DateFormat('dd MMMM yyyy').format(widget.progress.updatedAt!.toLocal())
        : DateFormat('dd MMMM yyyy').format(widget.progress.createdAt.toLocal());

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
                  // Title (Nama KPLT) and Expand Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.progress.kpltNama ?? 'Nama KPLT',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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

                  // Address
                  if (widget.progress.fullAddress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.progress.fullAddress,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Date with icon
                  Row(
                    children: [
                      Icon(
                        widget.progress.isCompleted 
                            ? Icons.check_circle_outline 
                            : Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 7),
                      Text(
                        widget.progress.isCompleted 
                            ? 'Selesai: $formattedDate' 
                            : 'Update: $formattedDate',
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
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.progress.readableStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        '${widget.progress.progressPercentage}%',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (widget.progress.progressPercentage / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildProgressDetail(),
            crossFadeState: _isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetail() {
    // Fetch completion status
    final statusAsync = ref.watch(completionStatusProvider(widget.progress.id));

    return statusAsync.when(
      data: (completionData) {
        // Build steps berdasarkan completion data
        final steps = _buildSteps(completionData);

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
                    'Detail Progress',
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
                
                if (step['isParallel'] == true) {
                  return _buildProgressStepItem(
                    step['title']!,
                    step['completed'] as bool,
                    null,
                    isLast,
                    isParallel: true,
                    subSteps: step['subSteps'] as List<Map<String, dynamic>>?,
                  );
                }
                
                return _buildProgressStepItem(
                  step['title']!,
                  step['completed'] as bool,
                  step['date'] as DateTime?,
                  isLast,
                );
              }),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error loading detail: $err',
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildSteps(Map<String, dynamic> completionData) {
    final steps = <Map<String, dynamic>>[];
    
    // 1. MOU
    final mouCompleted = completionData['mou']?['completed'] == true;
    steps.add({
      'title': 'MOU Process',
      'completed': mouCompleted,
      'date': completionData['mou']?['date'] != null
          ? DateTime.parse(completionData['mou']['date'])
          : null,
      'order': 1,
    });
    
    // Stop kalau MOU belum completed
    if (!mouCompleted) return steps;
    
    // 2 & 3. Izin Tetangga dan Perizinan (PARALLEL)
    final izinCompleted = completionData['izin_tetangga']?['completed'] == true;
    final perizinanCompleted = completionData['perizinan']?['completed'] == true;
    
    steps.add({
      'title': 'Izin Tetangga & Perizinan',
      'completed': izinCompleted && perizinanCompleted,
      'isParallel': true,
      'subSteps': [
        {
          'title': 'Izin Tetangga',
          'completed': izinCompleted,
          'date': completionData['izin_tetangga']?['date'] != null
              ? DateTime.parse(completionData['izin_tetangga']['date'])
              : null,
        },
        {
          'title': 'Perizinan',
          'completed': perizinanCompleted,
          'date': completionData['perizinan']?['date'] != null
              ? DateTime.parse(completionData['perizinan']['date'])
              : null,
        },
      ],
      'order': 2,
    });
    
    // Stop kalau salah satu parallel steps belum completed
    if (!izinCompleted || !perizinanCompleted) return steps;
    
    // 4. Notaris
    final notarisCompleted = completionData['notaris']?['completed'] == true;
    steps.add({
      'title': 'Notaris Process',
      'completed': notarisCompleted,
      'date': completionData['notaris']?['date'] != null
          ? DateTime.parse(completionData['notaris']['date'])
          : null,
      'order': 3,
    });
    
    if (!notarisCompleted) return steps;
    
    // 5. Renovasi
    final renovasiCompleted = completionData['renovasi']?['completed'] == true;
    steps.add({
      'title': 'Renovasi',
      'completed': renovasiCompleted,
      'date': completionData['renovasi']?['date'] != null
          ? DateTime.parse(completionData['renovasi']['date'])
          : null,
      'order': 4,
    });
    
    if (!renovasiCompleted) return steps;
    
    // 6. Grand Opening
    final grandOpeningCompleted = completionData['grand_opening']?['completed'] == true;
    steps.add({
      'title': 'Grand Opening',
      'completed': grandOpeningCompleted,
      'date': completionData['grand_opening']?['date'] != null
          ? DateTime.parse(completionData['grand_opening']['date'])
          : null,
      'order': 5,
    });
    
    return steps;
  }

  Widget _buildProgressStepItem(
    String title,
    bool isCompleted,
    DateTime? completedAt,
    bool isLast,
    {bool isParallel = false, List<Map<String, dynamic>>? subSteps}
  ) {
    if (isParallel && subSteps != null) {
      return _buildParallelSteps(subSteps, isLast);
    }
    
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
                    color: isCompleted ? AppColors.successColor : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? AppColors.successColor : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isCompleted 
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
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date info
                  if (isCompleted && completedAt != null)
                    Row(
                      children: [
                        Text(
                          'Selesai: ${DateFormat('dd MMM yyyy, HH:mm').format(completedAt.toLocal())}',
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
                          color: AppColors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Dalam Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.orange,
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
  
  Widget _buildParallelSteps(List<Map<String, dynamic>> subSteps, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dengan fork untuk parallel
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: subSteps.every((s) => s['completed'] == true)
                        ? AppColors.successColor
                        : Colors.transparent,
                    border: Border.all(
                      color: subSteps.every((s) => s['completed'] == true)
                          ? AppColors.successColor
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: subSteps.every((s) => s['completed'] == true)
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

          // Content - parallel items
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Row(
                    children: [
                      Icon(Icons.call_split, size: 16, color: AppColors.secondaryColor),
                      SizedBox(width: 6),
                      Text(
                        'Proses Perizinan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Sub items
                  ...List.generate(subSteps.length, (index) {
                    final subStep = subSteps[index];
                    final completed = subStep['completed'] as bool;
                    final date = subStep['date'] as DateTime?;
                    final isSubLast = index == subSteps.length - 1;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: isSubLast ? 0 : 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            completed ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 18,
                            color: completed ? AppColors.successColor : Colors.grey[400],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subStep['title'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: completed ? Colors.black87 : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (completed && date != null)
                                  Text(
                                    'Selesai: ${DateFormat('dd MMM yyyy').format(date.toLocal())}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                else
                                  Text(
                                    'Dalam Progress',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}