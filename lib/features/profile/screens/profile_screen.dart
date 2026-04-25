import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/user_service.dart';
import '../../home/providers/home_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfileScreen
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _dailyReminder = true;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.navy,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: profileAsync.when(
        data: (user) => user == null
            ? const Center(child: Text('Not signed in'))
            : _buildBody(user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(UserModel user) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Profile header ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.navy,
                  child: Text(
                    _initials(user.fullName),
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.gold,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.fullName,
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // CMA level pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'CMA ${user.level.displayName}',
                        style: GoogleFonts.dmSans(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Joined ${DateFormat('MMM yyyy').format(user.createdAt)}',
                      style: GoogleFonts.dmSans(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _showEditNameDialog(user),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.navy),
                    foregroundColor: AppColors.navy,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // ── Account section ───────────────────────────────────────────────
          _sectionHeader('ACCOUNT'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Edit Name',
                    onTap: () => _showEditNameDialog(user),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.email_outlined,
                    title: 'Change Email',
                    trailing: Text(
                      user.email,
                      style: GoogleFonts.dmSans(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () => _showChangePasswordDialog(),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.school_outlined,
                    title: 'CMA Level',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.level.displayName,
                            style: GoogleFonts.dmSans(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textSecondary, size: 16),
                      ],
                    ),
                    onTap: () => _showLevelSheet(user),
                  ),
                ],
              ),
            ),
          ),

          // ── Study Preferences ─────────────────────────────────────────────
          _sectionHeader('STUDY PREFERENCES'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Daily Reminder',
                    trailing: Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: _dailyReminder,
                        activeThumbColor: AppColors.gold,
                        activeTrackColor: AppColors.gold.withValues(alpha: 0.5),
                        onChanged: (val) async {
                          await HapticFeedback.lightImpact();
                          if (!mounted) return;
                          setState(() => _dailyReminder = val);
                          final svc = ref.read(notificationServiceProvider);
                          if (val) {
                            // ignore: use_build_context_synchronously
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(
                                  hour: 9, minute: 0),
                              helpText: 'Pick reminder time',
                            );
                            if (picked != null && mounted) {
                              final now = DateTime.now();
                              final target = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                picked.hour,
                                picked.minute,
                              );
                              await svc.scheduleDailyReminder(target);
                            }
                          } else {
                            await svc.cancelDailyReminder();
                          }
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'Exam Date',
                    trailing: user.examDate != null
                        ? Text(
                            _daysRemaining(user.examDate!),
                            style: GoogleFonts.dmSans(
                              color: AppColors.gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null,
                    onTap: () => _showExamDatePicker(user),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.tune_outlined,
                    title: 'Notification Preferences',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // ── App ───────────────────────────────────────────────────────────
          _sectionHeader('APP'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About Tutor Me',
                    trailing: Text(
                      'v1.0.0',
                      style: GoogleFonts.dmSans(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    onTap: () => _showAboutDialog(),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.star_outline_rounded,
                    title: 'Rate the App',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.flag_outlined,
                    title: 'Report a Problem',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.article_outlined,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // ── Account Actions ────────────────────────────────────────────────
          _sectionHeader('ACCOUNT ACTIONS'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    iconColor: AppColors.error,
                    titleColor: AppColors.error,
                    onTap: () => _confirmLogout(),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete Account',
                    iconColor: AppColors.error,
                    titleColor: AppColors.error,
                    onTap: () => _confirmDeleteAccount(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────────────

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      );

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  String _daysRemaining(DateTime examDate) {
    final diff = examDate.difference(DateTime.now()).inDays;
    if (diff <= 0) return 'Exam passed';
    return '$diff days remaining';
  }

  // ── Dialogs ─────────────────────────────────────────────────────────────────

  void _showEditNameDialog(UserModel user) {
    final ctrl = TextEditingController(text: user.fullName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(userServiceProvider)
                  .updateProfile(fullName: ctrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_reset_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Capture messengers before async gaps
              final rootMessenger = ScaffoldMessenger.of(context);
              final ctxMessenger = ScaffoldMessenger.of(ctx);
              try {
                await ref.read(authServiceProvider).reAuthenticate(
                      email: ref
                              .read(authStateChangesProvider)
                              .valueOrNull
                              ?.email ??
                          '',
                      password: currentCtrl.text,
                    );
                await ref
                    .read(authServiceProvider)
                    .updatePassword(newCtrl.text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  rootMessenger.showSnackBar(
                    const SnackBar(content: Text('Password updated!')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ctxMessenger.showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLevelSheet(UserModel user) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                'Select CMA Level',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            ...CmaLevel.values.map((level) {
              final isSelected = user.level == level;
              return ListTile(
                title: Text(
                  'CMA ${level.displayName}',
                  style: GoogleFonts.dmSans(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isSelected ? AppColors.navy : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.gold)
                    : null,
                onTap: () async {
                  await ref
                      .read(userServiceProvider)
                      .updateProfile(level: level);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showExamDatePicker(UserModel user) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: user.examDate ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    // Save to Firestore
    final uid = ref.read(authServiceProvider).currentUid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'examDate': Timestamp.fromDate(picked),
    });
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Tutor Me',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 TutorMe. All rights reserved.',
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authServiceProvider).signOut();
              if (mounted) context.go(AppRoutes.login);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 22),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⚠️ This cannot be undone. All your progress, bookmarks and results will be permanently deleted.',
                style: GoogleFonts.dmSans(
                    color: AppColors.error, fontSize: 13, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Type DELETE to confirm',
              style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                hintText: 'DELETE',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () async {
              if (ctrl.text != 'DELETE') {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content: Text('Please type DELETE to confirm')),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                final user = ref.read(authStateChangesProvider).valueOrNull;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .delete();
                  await user.delete();
                }
                if (mounted) context.go(AppRoutes.login);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingsTile — reusable settings row
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.navy;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: effectiveIconColor.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: effectiveIconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          color: titleColor ?? AppColors.navy,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 16)
              : null),
      onTap: onTap,
    );
  }
}
