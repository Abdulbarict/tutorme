import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../widgets/auth_shared_widgets.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedLevel; // 'inter' | 'final'

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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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

  Future<void> _onCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLevel == null) {
      _showError('Please select what you are preparing for.');
      return;
    }

    setState(() => _isLoading = true);
    _dismissError();

    try {
      final cred = await ref.read(authServiceProvider).signUp(
            email: _emailCtrl.text,
            password: _passCtrl.text,
          );

      await ref
          .read(authServiceProvider)
          .updateDisplayName(_nameCtrl.text.trim());

      final uid = cred.user!.uid;

      // Map signup chip value to CmaLevel enum
      final cmaLevel = _selectedLevel == 'inter'
          ? CmaLevel.intermediate
          : CmaLevel.final_;

      // FIX S2: Use UserService instead of raw FirebaseFirestore.instance.
      // Also adds the missing currentStreak / weeklyGoal / bestStreak fields
      // that homeStatsProvider depends on — without them the home screen always
      // shows demo fallback data, even for a fresh account.
      final newUser = UserModel(
        uid: uid,
        email: _emailCtrl.text.trim(),
        fullName: _nameCtrl.text.trim(),
        level: cmaLevel,
        createdAt: DateTime.now(),
      );

      await ref.read(userServiceProvider).createUserProfile(newUser);

      // Also write streak/goal fields not covered by UserModel.toMap()
      await ref.read(userServiceProvider).initUserStats();

      if (!mounted) return;

      // FIX S4: User already chose their level during signup, so go straight
      // to /home rather than /level-select (which would write the level again).
      context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.errorMessage(e));
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              title: 'Join Tutor Me',
              subtitle: 'Start your CMA journey',
            ),

            // ── White card ────────────────────────────────────────────
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
                          'Create Account',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fill in your details to get started',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Full Name
                        AuthTextField(
                          controller: _nameCtrl,
                          label: 'Full Name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Name is required';
                            }
                            if (v.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

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
                            if (v.length < 6) {
                              return 'At least 6 characters required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Confirm Password
                        AuthTextField(
                          controller: _confirmCtrl,
                          label: 'Confirm Password',
                          prefixIcon: Icons.shield_outlined,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (v != _passCtrl.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Level label
                        Text(
                          'I am preparing for:',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Level chips
                        Row(
                          children: [
                            Expanded(
                              child: _LevelChip(
                                label: 'CMA Inter',
                                isSelected: _selectedLevel == 'inter',
                                onTap: () =>
                                    setState(() => _selectedLevel = 'inter'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _LevelChip(
                                label: 'CMA Final',
                                isSelected: _selectedLevel == 'final',
                                onTap: () =>
                                    setState(() => _selectedLevel = 'final'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Create Account button
                        AppButton.secondary(
                          label: 'Create Account',
                          onPressed: _isLoading ? null : _onCreateAccount,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        const AuthOrDivider(),
                        const SizedBox(height: AppSpacing.lg),

                        const AuthGoogleButton(),
                        const SizedBox(height: AppSpacing.lg),

                        // Login link
                        Center(
                          child: GestureDetector(
                            onTap: () => context.go(AppRoutes.login),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  const TextSpan(
                                      text: 'Already have an account?  '),
                                  TextSpan(
                                    text: 'Login',
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

            // ── Error banner ──────────────────────────────────────────
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

// ── Level chip ────────────────────────────────────────────────────────────────

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.navy : AppColors.border,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
