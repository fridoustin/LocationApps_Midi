import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/penugasan/domain/entities/tracking_point.dart';

class AssignmentTrackingHistory extends StatelessWidget {
  final AsyncValue<List<TrackingPoint>> trackingHistoryAsync;

  const AssignmentTrackingHistory({
    super.key,
    required this.trackingHistoryAsync,
  });

  @override
  Widget build(BuildContext context) {
    return trackingHistoryAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const Text('Belum ada tracking history');
        }

        final sortedHistory = history.toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return Column(
          children: sortedHistory.map((point) {
            return _TrackingHistoryItem(point: point);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

class _TrackingHistoryItem extends StatelessWidget {
  final TrackingPoint point;

  const _TrackingHistoryItem({required this.point});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _getIcon(point.status),
        color: _getColor(point.status),
      ),
      title: Text(point.notes ?? _getStatusText(point.status)),
      subtitle: Text(
        DateFormat('dd MMM yyyy, HH:mm').format(point.createdAt),
      ),
      trailing: point.notes != null
          ? Tooltip(
              message: point.notes!,
              child: const Icon(Icons.info_outline, size: 20),
            )
          : null,
    );
  }

  IconData _getIcon(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.arrived:
        return Icons.check_circle;
      case TrackingStatus.pending:
        return Icons.pending;
      case TrackingStatus.cancelled:
        return Icons.cancel;
      case TrackingStatus.inTransit:
        return Icons.directions_walk;
    }
  }

  Color _getColor(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.arrived:
        return AppColors.successColor;
      case TrackingStatus.pending:
        return AppColors.warningColor;
      case TrackingStatus.cancelled:
        return Colors.red;
      case TrackingStatus.inTransit:
        return AppColors.blue;
    }
  }

  String _getStatusText(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.arrived:
        return 'Check-in berhasil';
      case TrackingStatus.pending:
        return 'Pending';
      case TrackingStatus.cancelled:
        return 'Dibatalkan';
      case TrackingStatus.inTransit:
        return 'Dalam perjalanan';
    }
  }
}