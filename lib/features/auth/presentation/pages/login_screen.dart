import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/utils/show_error_dialog.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  static const String route = '/login';
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    // Validasi sederhana
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password tidak boleh kosong')),
      );
      return;
    }

    // Set state loading menjadi true
    setState(() {
      _isLoading = true;
    });

    try {
      // 'ref.read' digunakan untuk action/fungsi
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      // Jika berhasil, AuthGate akan otomatis mengarahkan ke halaman utama.
    } catch (e) {
      // Jika gagal, tangani error dan tampilkan pesan
      if (mounted) {
        // Pastikan widget masih ada di tree
        final errorMessage = e.toString().replaceAll("Exception: ", "");
        showErrorDialog(context, errorMessage);
      }
    } finally {
      // Set state loading kembali ke false setelah selesai (baik berhasil maupun gagal)
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/pic/bg_2.png"),
          fit: BoxFit.cover,
        ),
      ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        Image.asset('assets/pic/alfamididown.png', width: 120),

                        const SizedBox(height: 30),

                        // Description text
                        const Text(
                          'Platform digital terpusat untuk proses\npengembangan lokasi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Login Form Container
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Log In title
                              const Center(
                                child: Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Email field
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD32F2F),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Password field
                              const Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD32F2F),
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Log In button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD32F2F),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text(
                                            'Log In',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer tetap di bawah
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Prototype @2025 Location Team App',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        )
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
