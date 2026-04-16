import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Navigation Shell
// ─────────────────────────────────────────────────────────────────────────────

/// StatefulWidget shell that wraps GoRouter's [ShellRoute] child.
/// Each screen manages its own header — no AppBar is rendered here.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.navigationShell,
  });

  /// The [StatefulNavigationShell] provided by [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _tabs = <_NavItem>[
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: AppRoutes.home,
    ),
    _NavItem(
      label: 'Subjects',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      route: AppRoutes.subjects,
    ),
    _NavItem(
      label: 'Practice',
      icon: Icons.lightbulb_outline,
      activeIcon: Icons.lightbulb,
      route: AppRoutes.practiceConfig,
    ),
    _NavItem(
      label: 'Tests',
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer,
      route: AppRoutes.testConfig,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: AppRoutes.profile,
    ),
  ];

  void _onTap(int index) {
    if (index == widget.navigationShell.currentIndex) {
      // Pop-to-root on double-tap of same tab
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    } else {
      widget.navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.navigationShell,
      bottomNavigationBar: _BottomNav(
        currentIndex: currentIndex,
        tabs: _tabs,
        onTap: _onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavItem> tabs;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x100F2D5E),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: tabs.asMap().entries.map((entry) {
              final i = entry.key;
              final tab = entry.value;
              final isActive = i == currentIndex;
              return Expanded(
                child: _NavBarItem(
                  item: tab,
                  isActive: isActive,
                  onTap: () => onTap(i),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon + gold dot indicator
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                size: 24,
                color: isActive ? AppColors.navy : AppColors.textSecondary,
              ),
              if (isActive)
                Positioned(
                  bottom: -5,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: isActive ? AppColors.navy : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}
