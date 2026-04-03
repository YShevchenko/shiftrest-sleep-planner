import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/schedule_screen.dart';
import 'presentation/screens/sleep_plan_screen.dart';
import 'presentation/screens/circadian_screen.dart';
import 'presentation/screens/dark_room_screen.dart';
import 'presentation/screens/wind_down_screen.dart';
import 'presentation/screens/nap_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/settings_screen.dart';

class ShiftRestApp extends StatelessWidget {
  const ShiftRestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShiftRest',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
      routes: {
        '/dark-room': (_) => const DarkRoomScreen(),
        '/wind-down': (_) => const WindDownScreen(),
        '/nap': (_) => const NapScreen(),
      },
    );
  }
}

/// Main app shell with bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    ScheduleScreen(),
    SleepPlanScreen(),
    CircadianScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(context),
      // Quick action buttons
      floatingActionButton: _currentIndex == 0
          ? null // Schedule screen has its own FAB
          : _buildQuickActions(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.06),
            blurRadius: 64,
            offset: const Offset(0, 32),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9999),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 64,
          indicatorColor: AppColors.surfaceContainerHigh,
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined,
                  color: AppColors.onSurface.withValues(alpha: 0.5)),
              selectedIcon: const Icon(Icons.dashboard, color: AppColors.primary),
              label: 'Schedule',
            ),
            NavigationDestination(
              icon: Icon(Icons.bedtime_outlined,
                  color: AppColors.onSurface.withValues(alpha: 0.5)),
              selectedIcon: const Icon(Icons.bedtime, color: AppColors.primary),
              label: 'Sleep',
            ),
            NavigationDestination(
              icon: Icon(Icons.donut_large_outlined,
                  color: AppColors.onSurface.withValues(alpha: 0.5)),
              selectedIcon: const Icon(Icons.donut_large, color: AppColors.primary),
              label: 'Circadian',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined,
                  color: AppColors.onSurface.withValues(alpha: 0.5)),
              selectedIcon: const Icon(Icons.history, color: AppColors.primary),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined,
                  color: AppColors.onSurface.withValues(alpha: 0.5)),
              selectedIcon: const Icon(Icons.settings, color: AppColors.primary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildQuickActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dark Room
        FloatingActionButton.small(
          heroTag: 'dark_room',
          onPressed: () => Navigator.of(context).pushNamed('/dark-room'),
          backgroundColor: AppColors.surfaceContainerHigh,
          child: const Icon(Icons.dark_mode, color: AppColors.onSurfaceVariant, size: 20),
        ),
        const SizedBox(height: 8),
        // Wind Down
        FloatingActionButton.small(
          heroTag: 'wind_down',
          onPressed: () => Navigator.of(context).pushNamed('/wind-down'),
          backgroundColor: AppColors.surfaceContainerHigh,
          child: const Icon(Icons.self_improvement, color: AppColors.onSurfaceVariant, size: 20),
        ),
        const SizedBox(height: 8),
        // Nap
        FloatingActionButton.small(
          heroTag: 'nap',
          onPressed: () => Navigator.of(context).pushNamed('/nap'),
          backgroundColor: AppColors.surfaceContainerHigh,
          child: const Icon(Icons.snooze, color: AppColors.onSurfaceVariant, size: 20),
        ),
      ],
    );
  }
}
