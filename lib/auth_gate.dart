// lib/auth_gate.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/services/notification_service.dart';
import 'package:midi_location/core/widgets/main_layout.dart';
import 'package:midi_location/features/auth/presentation/pages/login_screen.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/kplt_notification_handler_page.dart';
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
    ref.listen<Map<String, dynamic>?>(initialNotificationProvider, (
      previous,
      next,
    ) {
      if (next != null) {
        final screen = next['screen'];
        final ulokId = next['ulokId'];

        if (screen == '/form-kplt' && ulokId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => KpltNotificationHandlerPage(ulokId: ulokId),
            ),
          );
          ref.read(initialNotificationProvider.notifier).state = null;
        }
      }
    });

    ref.listen(authStateProvider, (previous, next) {
      final user = next.valueOrNull;

      if (user != null) {
        ref.invalidate(userProfileProvider);
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(ulokListProvider);
        ref.invalidate(notificationListProvider);
        ref.invalidate(ulokTabProvider);
        ref.invalidate(kpltNeedInputProvider);
        ref.invalidate(kpltInProgressProvider);
        ref.invalidate(kpltHistoryProvider);
      }
    });

    final connectivityStatus = ref.watch(connectivityProvider);
    final authState = ref.watch(authStateProvider);

    if (connectivityStatus.isLoading || authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (connectivityStatus.hasError) {
      return Scaffold(
        body: Center(
          child: Text('Terjadi error koneksi: ${connectivityStatus.error}'),
        ),
      );
    }
    if (authState.hasError) {
      try {
        ref.read(supabaseClientProvider).auth.signOut();
      } catch (_) {}
      return const LoginPage();
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
