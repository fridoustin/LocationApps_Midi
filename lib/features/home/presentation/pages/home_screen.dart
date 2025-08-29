// 1. Import Riverpod dan provider auth
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart'; // Sesuaikan path jika perlu

// 2. Ubah menjadi ConsumerWidget
class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  static const String route = '/home';

  @override
  // 3. Tambahkan WidgetRef ref pada method build
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 100, color: Colors.red[300]),
          const SizedBox(height: 20),
          Text(
            'Home Page',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 40),

          // 4. Tambahkan Tombol Logout
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // 5. Panggil fungsi signOut dari provider
              ref.read(authRepositoryProvider).signOut();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}