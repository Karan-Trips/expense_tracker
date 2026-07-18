import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        context.goNamed('home');
        break;
      case 1:
        context.goNamed('expenses');
        break;
      case 2:
        context.goNamed('scanner');
        break;
      case 3:
        context.goNamed('insights');
        break;
    }
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.border.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          title: Row(
            children: const [
              Icon(
                Icons.exit_to_app_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                "Exit AuraExpense?",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to close the application?",
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.9),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            // Cancel button
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "Cancel",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            // Exit button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 38),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Exit",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog(context);
        if (shouldExit == true) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
