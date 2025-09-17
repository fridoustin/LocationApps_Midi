import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/utils/show_error_dialog.dart';
import 'package:midi_location/features/auth/presentation/pages/login_screen.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';

class UpdatePasswordPage extends ConsumerStatefulWidget {
  const UpdatePasswordPage({super.key});
  static const String route = '/update-password';

  @override
  ConsumerState<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      showErrorDialog(context, 'Password tidak boleh kosong.');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      showErrorDialog(context, 'Konfirmasi password tidak cocok.');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      // Langkah 1: Update password di Supabase
      await ref.read(authRepositoryProvider).updateUserPassword(_passwordController.text);
      
      // Langkah 2: Logout untuk membersihkan sesi recovery. Ini sangat penting.
      await ref.read(authRepositoryProvider).signOut();

      // Langkah 3: Beri tahu pengguna dan navigasi HANYA JIKA SEMUA BERHASIL
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diperbarui! Silakan login kembali.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigasi ke LoginPage dan hapus semua halaman sebelumnya dari stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, e.toString().replaceAll("Exception: ", ""));
      }
    } finally {
      // Pastikan loading state selalu kembali normal, bahkan jika widget sudah unmounted
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Style yang sama dengan login
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/pic/bg_2.png"), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Buat Password Baru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Konfirmasi Password Baru', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Simpan Password Baru', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}