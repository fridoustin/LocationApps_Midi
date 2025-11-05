import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/utils/show_error_dialog.dart';
import 'package:midi_location/core/utils/auth_secure.dart';
import 'package:midi_location/core/utils/biometric_auth.dart';
import 'package:midi_location/features/auth/presentation/pages/forgot_password_screen.dart';
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
  bool _rememberMe = false;
  bool _enableBiometric = false;
  bool _biometricAvailable = false;
  bool _initializingBiometricState = true;

  @override
  void initState() {
    super.initState();
    _initBiometricState();
    _loadSavedCredentialsIfAny();
  }

  Future<void> _initBiometricState() async {
    final canBio = await BiometricAuth.canAuthenticateBiometrics();
    final enabled = await BiometricAuth.isBiometricEnabled();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = canBio;
      _enableBiometric = enabled;
      _initializingBiometricState = false;
    });
  }

  Future<void> _loadSavedCredentialsIfAny() async {
    final creds = await SecureAuth.readCredentials();
    if (!mounted) return;
    if (creds != null) {
      setState(() {
        _emailController.text = creds['email'] ?? '';
        _passwordController.text = creds['password'] ?? '';
        _rememberMe = true;
      });
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showErrorDialog(
        context,
        'Email dan Password tidak boleh kosong',
        title: 'Input Tidak Lengkap',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      final supabase = ref.read(supabaseClientProvider);
      final session = supabase.auth.currentSession;

      if (session != null) {
        if (_rememberMe) {
          await SecureAuth.saveCredentials(
            _emailController.text.trim(),
            _passwordController.text,
          );
        } else {
          await SecureAuth.clearSavedCredentials();
        }

        if (_enableBiometric && _biometricAvailable) {
          await BiometricAuth.enableBiometric(
            _emailController.text.trim(),
            _passwordController.text,
          );
          if (!_rememberMe) {
            setState(() => _rememberMe = true);
            await SecureAuth.saveCredentials(
              _emailController.text.trim(),
              _passwordController.text,
            );
          }
        } else {
          if (!_enableBiometric) {
            await BiometricAuth.disableBiometric();
          }
        }
      } else {
        showErrorDialog(context, 'Gagal masuk: sesi tidak tersedia', title: 'Login Gagal');
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll("Exception: ", "");
        showErrorDialog(context, errorMessage, title: 'Login Gagal');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildRememberAndForgotRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Transform.translate(
                offset: const Offset(-12, 0),
                child: Checkbox(
                  visualDensity: VisualDensity.compact,
                  checkColor: AppColors.white,
                  activeColor: AppColors.primaryColor,
                  value: _rememberMe,
                  onChanged: (v) {
                    setState(() {
                      _rememberMe = v ?? false;
                      if (!_rememberMe && _enableBiometric) {
                        _enableBiometric = false;
                        BiometricAuth.disableBiometric();
                      }
                    });
                  },
                ),
              ),
              Transform.translate(
                offset: const Offset(-12, 0),
                child: const Text(
                  'Remember me',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.pushNamed(context, ForgotPasswordPage.route);
                  },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Lupa Password?',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricToggle() {
    if (_initializingBiometricState) {
      return const SizedBox.shrink();
    }

    if (!_biometricAvailable) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 6.0),
      child: Row(
        children: [
          Transform.translate(
            offset: const Offset(-12, 0),
            child: Checkbox(
              visualDensity: VisualDensity.compact,
              checkColor: AppColors.white,
              activeColor: AppColors.primaryColor,
              value: _enableBiometric,
              onChanged: (v) async {
                final enabled = v ?? false;
                if (enabled && !_rememberMe) {
                  setState(() {
                    _rememberMe = true;
                    _enableBiometric = true;
                  });
                  if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                    await SecureAuth.saveCredentials(
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                    await BiometricAuth.enableBiometric(
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                  } else {
                    setState(() {
                      _enableBiometric = true;
                    });
                  }
                } else {
                  setState(() {
                    _enableBiometric = enabled;
                  });
                  if (!enabled) {
                    await BiometricAuth.disableBiometric();
                  }
                }
              },
            ),
          ),
          Transform.translate(
            offset: const Offset(-12, 0),
            child: const Text(
              'Enable biometric login',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                keyboardType: TextInputType.emailAddress,
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
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                              const SizedBox(height: 8),
                              _buildRememberAndForgotRow(),
                              _buildBiometricToggle(),

                              const SizedBox(height: 10),
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
                                  child: _isLoading
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
              const Padding(
                padding: EdgeInsets.only(bottom: 8, top: 8),
                child: Text(
                  'Prototype @2025 Location Team App',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
