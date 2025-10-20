import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/main_layout.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/kplt_notification_handler_page.dart';
import 'package:midi_location/features/notification/presentation/provider/notification_provider.dart';
import 'package:midi_location/features/lokasi/presentation/pages/ulok_detail_screen.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  static const String route = '/notification';

  // Helper untuk format waktu relatif
  String _formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} Menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} Jam yang lalu';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} Hari yang lalu';
    } else {
      return DateFormat('dd MMMM yyyy').format(time);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: "Notification",
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset("assets/icons/left_arrow.svg",
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text("Tidak ada notifikasi."));
          }
          return RefreshIndicator(
            color: AppColors.primaryColor,
            backgroundColor: Colors.white,
            onRefresh: () => ref.refresh(notificationListProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return GestureDetector(
                  onTap: () async {
                    await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
                    ref.invalidate(notificationListProvider);
                    if (notification.ulokId != null && context.mounted) {
                      if (notification.ulokStatus == 'NOK') {
                        final ulokDetails = await ref.read(ulokByIdProvider(notification.ulokId!).future);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UlokDetailPage(ulok: ulokDetails)),
                        );
                      } 
                      else if (notification.ulokStatus == 'OK') {
                        if (notification.kpltId == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KpltNotificationHandlerPage(ulokId: notification.ulokId!),
                            ),
                          );
                        } 
                        else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MainLayout(currentIndex: 2)),
                          );
                        }
                      }
                    }
                  },
                  child: Card(
                    color: AppColors.cardColor,
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification.body,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatRelativeTime(notification.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!notification.isRead)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 4),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor, backgroundColor: Color(0xFFFFFFFF),)),
        error: (err, stack) => Center(child: Text("Gagal memuat notifikasi: $err")),
      ),
    );
  }
}
