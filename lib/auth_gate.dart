// lib/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/widgets/main_layout.dart';
import 'package:midi_location/features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau authStateProvider
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // Jika ada data user (berhasil login), tampilkan MainLayout
        if (user != null) {
          // Inilah yang Anda inginkan!
          return const MainLayout(currentIndex: 0);
        }
        // Jika data user null (belum login/logout), tampilkan LoginPage
        return const LoginPage(); // Pastikan Anda sudah membuat halaman ini
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