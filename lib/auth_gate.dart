// lib/auth_gate.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/services/notification_service.dart';
import 'package:midi_location/core/utils/auth_secure.dart';
import 'package:midi_location/core/widgets/main_layout.dart';
import 'package:midi_location/features/auth/presentation/pages/login_screen.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/lokasi/presentation/pages/kplt_notification_handler_page.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/notification/presentation/provider/notification_provider.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_form_provider.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _isAttemptingRestore = false;
  bool? _restoreResult;
  bool _listenersInitialized = false;

  @override
  void initState() {
    super.initState();

    // Auto-login from saved credentials once after first frame (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final client = ref.read(supabaseClientProvider);
      final session = client.auth.currentSession;
      if (session == null) {
        final auto = await SecureAuth.tryAutoLoginFromSavedCredentials();
        if (auto) {
          // jika berhasil -> invalidate provider agar data terfetch ulang
          ref.invalidate(userProfileProvider);
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(ulokListProvider);
          ref.invalidate(notificationListProvider);
          ref.invalidate(ulokTabProvider);
          ref.invalidate(kpltNeedInputProvider);
          ref.invalidate(kpltInProgressProvider);
          ref.invalidate(kpltHistoryProvider);
        }
      }
    });
  }

  Future<bool> _tryRestoreSession() async {
    final client = ref.read(supabaseClientProvider);
    try {
      final res = await client.auth.refreshSession();
      final sess = res.session ?? client.auth.currentSession;
      return sess != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> _attemptRestoreAndAct() async {
    if (_isAttemptingRestore) return;
    _isAttemptingRestore = true;
    setState(() {
      _restoreResult = null;
    });

    final restored = await _tryRestoreSession();

    if (!mounted) return;
    setState(() {
      _restoreResult = restored;
      _isAttemptingRestore = false;
    });

    if (restored) {
      ref.invalidate(userProfileProvider);
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(ulokListProvider);
      ref.invalidate(notificationListProvider);
      ref.invalidate(ulokTabProvider);
      ref.invalidate(kpltNeedInputProvider);
      ref.invalidate(kpltInProgressProvider);
      ref.invalidate(kpltHistoryProvider);
    } else {
      try {
        await ref.read(supabaseClientProvider).auth.signOut();
      } catch (_) {}
      if (mounted) {
        try {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // register listeners once inside build to satisfy Riverpod's rules
    if (!_listenersInitialized) {
      _listenersInitialized = true;

      // Listener untuk initial notification
      ref.listen<Map<String, dynamic>?>(initialNotificationProvider, (prev, next) {
        if (next != null) {
          final screen = next['screen'];
          final ulokId = next['ulokId'];

          if (screen == '/form-kplt' && ulokId != null) {
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => KpltNotificationHandlerPage(ulokId: ulokId),
                ),
              );
            }
            ref.read(initialNotificationProvider.notifier).state = null;
          }
        }
      });

      // Listener untuk authStateProvider -> invalidate provider saat user berubah
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
    }

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
    final hasConnection = connectivityStatus.value != ConnectivityResult.none;

    if (authState.hasError) {
      if (hasConnection) {
        if (_restoreResult != true && !_isAttemptingRestore) {
          _attemptRestoreAndAct();
        }

        if (_isAttemptingRestore || _restoreResult == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (_restoreResult == false) {
          return const LoginPage();
        }

        final user = ref.read(supabaseClientProvider).auth.currentUser;
        if (user != null) {
          return const MainLayout(currentIndex: 0);
        } else {
          return const LoginPage();
        }
      } else {
        final session = ref.read(supabaseClientProvider).auth.currentSession;
        if (session != null) {
          return const MainLayout(currentIndex: 0);
        }
        return const LoginPage();
      }
    }
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
