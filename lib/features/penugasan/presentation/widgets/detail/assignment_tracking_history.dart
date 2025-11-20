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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: trackingHistoryAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_toggle_off,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat tracking',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
            
            final sortedHistory = history.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedHistory.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final point = sortedHistory[index];
              final isLast = index == sortedHistory.length - 1;
              
              return _HistoryItem(
                point: point, 
                isLast: isLast
              );
            },
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Gagal memuat history: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final TrackingPoint point;
  final bool isLast;

  const _HistoryItem({required this.point, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getColor(point.status),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getColor(point.status).withOpacity(0.3),
                      width: 3
                    )
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      // Garis putus-putus (Dotted) manual atau solid pudar
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getStatusTitle(point.status),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm, dd MMM').format(point.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    point.notes ?? _getStatusDesc(point.status),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
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

  String _getStatusTitle(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.arrived: return 'Tiba di Lokasi';
      case TrackingStatus.pending: return 'Status Pending';
      case TrackingStatus.cancelled: return 'Dibatalkan';
      case TrackingStatus.inTransit: return 'Dalam Perjalanan';
    }
  }
  
  String _getStatusDesc(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.arrived: return 'User telah melakukan check-in';
      case TrackingStatus.pending: return 'Menunggu konfirmasi';
      case TrackingStatus.cancelled: return 'Aktivitas dibatalkan';
      case TrackingStatus.inTransit: return 'User sedang menuju lokasi';
    }
  }
}