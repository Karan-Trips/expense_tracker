import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/db_service.dart';
import '../../../core/locator/locator.dart';
import '../../../core/constant/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ValueNotifier<String> _statusText = ValueNotifier("Starting AuraExpense...");
  final ValueNotifier<String?> _errorText = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _statusText.dispose();
    _errorText.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      _statusText.value = "Loading Environment Configuration...";
      _errorText.value = null;
      // Load environment variables
      await dotenv.load(fileName: ".env");

      _statusText.value = "Initializing Local Database...";
      // Init Database
      await DbService.init();

      _statusText.value = "Injecting App Modules...";
      // Set up GetIt DI
      await setupLocator();

      // Small delay for clean aesthetics
      await Future.delayed(const Duration(milliseconds: 1200));

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      _errorText.value = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF0F0E26)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Aesthetic Banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0x3300FFCC), Colors.transparent],
                    radius: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: AppColors.accentTeal,
                ),
              ),
              const SizedBox(height: ScreenUtils.margin),
              const Text(
                "A U R A",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtils.fontTextTitle,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: ScreenUtils.spacingStandardControl),
              const Text(
                "AI EXPENSE TRACKER",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: ScreenUtils.fontTextSmaller,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 48),
              AnimatedBuilder(
                animation: Listenable.merge([_statusText, _errorText]),
                builder: (context, _) {
                  final errorText = _errorText.value;
                  final statusText = _statusText.value;

                  if (errorText == null) {
                    return Column(
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                          ),
                        ),
                        const SizedBox(height: ScreenUtils.spacingStander),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: ScreenUtils.fontTextSmall,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 40),
                          const SizedBox(height: ScreenUtils.spacingControl),
                          Text(
                            errorText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: ScreenUtils.fontTextSmall,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _initializeApp,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // Continue with error flagged (local DB offline or mockup only)
                              context.go('/home');
                            },
                            child: const Text(
                              "Skip & Continue Offline",
                              style: TextStyle(color: AppColors.accentTeal),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
