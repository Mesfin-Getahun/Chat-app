import 'package:flutter/material.dart';
import '../providers/app_state_provider.dart';
import '../core/app_theme.dart';
import 'dashboard_screen.dart';
import 'chat_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class HomeNavigationScreen extends StatefulWidget {
  final AppStateProvider provider;

  const HomeNavigationScreen({super.key, required this.provider});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        provider: widget.provider,
        onNavigateTab: _onTabTapped,
      ),
      ChatScreen(
        provider: widget.provider,
      ),
      AnalyticsScreen(
        provider: widget.provider,
      ),
      SettingsScreen(
        provider: widget.provider,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: AppTheme.bgDark,
          border: Border(
            top: BorderSide(
              color: AppTheme.dividerColor,
              width: 0.6,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.favorite_border_rounded, Icons.favorite_rounded, 'Hub'),
              _buildNavItem(1, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'),
              _buildNavItem(2, Icons.bar_chart_rounded, Icons.bar_chart_rounded, 'Analytics'),
              _buildNavItem(3, Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF28203E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : outlineIcon,
              size: 22,
              color: isSelected ? const Color(0xFFC4B5FD) : AppTheme.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
