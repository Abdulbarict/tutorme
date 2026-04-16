import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../widgets/auth_shared_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _errorCtrl;
  late final Animation<double> _errorSlide;

  @override
  void initState() {
    super.initState();
    _errorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _errorSlide = CurvedAnimation(parent: _errorCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _errorCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    setState(() => _errorMessage = msg);
    _errorCtrl.forward(from: 0);
  }

  void _dismissError() {
    _errorCtrl.reverse().then((_) {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    _dismissError();

    try {
      await ref.read(authServiceProvider).signIn(
            email: _emailCtrl.text,
            password: _passCtrl.text,
          );

      if (!mounted) return;

      final profile = await ref.read(firestoreServiceProvider).getUserProfile();
      if (!mounted) return;

      if (profile == null) {
        context.go(AppRoutes.levelSelect);
      } else {
        context.go(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.errorMessage(e));
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onForgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Enter your email address first.');
      return;
    }
    try {
      await ref.read(authServiceProvider).sendPasswordReset(email);
      if (!mounted) return;
      _showError('Password reset email sent! Check your inbox.');
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top navy banner ──────────────────────────────────────
            const AuthNavyBanner(
              title: 'Tutor Me',
              subtitle: 'CMA Prep',
            ),

            // ── White card overlapping banner ────────────────────────
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F0F2D5E),
                        blurRadius: 32,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Continue your CMA preparation',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Email
                        AuthTextField(
                          controller: _emailCtrl,
                          label: 'Email Address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(v)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Password
                        AuthTextField(
                          controller: _passCtrl,
                          label: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePass,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _onForgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: AppColors.gold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Login button
                        AppButton.primary(
                          label: 'Login',
                          onPressed: _isLoading ? null : _onLogin,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        const AuthOrDivider(),
                        const SizedBox(height: AppSpacing.lg),

                        const AuthGoogleButton(),
                        const SizedBox(height: AppSpacing.xl),

                        // Sign up link
                        Center(
                          child: GestureDetector(
                            onTap: () => context.go(AppRoutes.signup),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  const TextSpan(text: 'New here?  '),
                                  TextSpan(
                                    text: 'Create Account',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: AppColors.navy,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Animated error banner ────────────────────────────────
            if (_errorMessage != null)
              SizeTransition(
                sizeFactor: _errorSlide,
                child: FadeTransition(
                  opacity: _errorSlide,
                  child: AuthErrorBanner(
                    message: _errorMessage!,
                    onDismiss: _dismissError,
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
