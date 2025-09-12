import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/widgets/main_layout.dart';
import 'package:midi_location/features/auth/presentation/pages/login_screen.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/notification/presentation/provider/notification_provider.dart';
import 'package:midi_location/features/ulok/presentation/providers/ulok_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (previous, next) {
      final isLoggedIn = next.valueOrNull != null;
      final wasLoggedOut = previous?.valueOrNull == null;

      if (isLoggedIn && wasLoggedOut) {
        ref.invalidate(userProfileProvider);
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(ulokListProvider);
        ref.invalidate(kpltListProvider);
        ref.invalidate(notificationListProvider);
        ref.invalidate(timeRangeProvider);
        ref.invalidate(ulokTabProvider);
        ref.invalidate(kpltTabProvider);
      }
    });
    // Pantau authStateProvider
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // Jika ada data user (berhasil login), tampilkan MainLayout
        if (user != null) {
          return const MainLayout(currentIndex: 0);
        }
        // Jika data user null (belum login/logout), tampilkan LoginPage
        return const LoginPage();
      },
      // Tampilkan loading indicator saat status sedang diperiksa
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      // Tampilkan pesan error jika ada masalah
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Terjadi error: $err')),
      ),
    );
  }
}