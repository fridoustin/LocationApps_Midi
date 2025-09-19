import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/widgets/main_layout.dart';
import 'package:midi_location/features/auth/presentation/pages/login_screen.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/notification/presentation/provider/notification_provider.dart';
import 'package:midi_location/features/ulok/presentation/providers/ulok_form_provider.dart';
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
        ref.invalidate(notificationListProvider);
        ref.invalidate(timeRangeProvider);
        ref.invalidate(ulokTabProvider);
        ref.invalidate(kpltNeedInputProvider);
        ref.invalidate(kpltInProgressProvider);
        ref.invalidate(kpltHistoryProvider);
      }
    });

    final connectivityStatus = ref.watch(connectivityProvider);
    final authState = ref.watch(authStateProvider);

    if (connectivityStatus.isLoading || authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (connectivityStatus.hasError || authState.hasError) {
      return Scaffold(
        body: Center(child: Text('Terjadi error: ${connectivityStatus.error ?? authState.error}')),
      );
    }

    final hasConnection = connectivityStatus.value != ConnectivityResult.none;

    if (hasConnection) {
      final user = authState.value;
      if (user != null) {
        return const MainLayout(currentIndex: 0);
      }
      return const LoginPage();
    } else {
      final session = ref.read(supabaseClientProvider).auth.currentSession;
      if (session != null) {
        return const MainLayout(currentIndex: 0);
      }
      return const LoginPage();
    }
  }
}