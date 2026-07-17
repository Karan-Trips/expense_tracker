import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constant/app_colors.dart';
import '../../../widgets/frosted_card.dart';

class MainNavigationScreen extends StatelessWidget {
  final Widget child;

  const MainNavigationScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/expenses')) return 1;
    if (location.startsWith('/scanner')) return 2;
    if (location.startsWith('/insights')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/expenses');
        break;
      case 2:
        context.go('/scanner');
        break;
      case 3:
        context.go('/insights');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: child),
          // Floating Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: FrostedCard(
              blur: 20,
              opacity: 0.1,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              borderRadius: 24,
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => _onItemTapped(index, context),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppColors.accentTeal,
                  unselectedItemColor: AppColors.textSecondary,
                  selectedFontSize: 11,
                  unselectedFontSize: 10,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_outlined),
                      activeIcon: Icon(Icons.dashboard, color: AppColors.accentTeal),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.history_outlined),
                      activeIcon: Icon(Icons.history, color: AppColors.accentTeal),
                      label: 'History',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.document_scanner_outlined),
                      activeIcon: Icon(Icons.document_scanner, color: AppColors.accentTeal),
                      label: 'AI Scan',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.insights_outlined),
                      activeIcon: Icon(Icons.insights, color: AppColors.accentTeal),
                      label: 'Insights',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
