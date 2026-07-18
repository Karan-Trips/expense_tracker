import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../core/services/db_service.dart';
import '../../../core/locator/locator.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/services/notification_service.dart';

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
      await dotenv.load(fileName: ".env");

      _statusText.value = "Initializing Local Database...";
      await DbService.init();

      _statusText.value = "Injecting App Modules...";
      await setupLocator();

      _statusText.value = "Configuring Local Notification Channels...";
      await NotificationService.init();

      await Future.delayed(const Duration(milliseconds: 1200));

      if (mounted) {
        context.goNamed('home');
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
            colors: [AppColors.background, Color(0xFF0F1220)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentTeal.withOpacity(0.25),
                      blurRadius: 35,
                      spreadRadius: 4,
                    ),
                  ],
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentTeal.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                  ),
                ),
                child: Lottie.network(
                  'https://lottie.host/9c3c121e-fa2a-43c3-8a3a-1d54e4df9c2c/TqFk1Wb8p0.json',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.auto_awesome,
                      size: 68,
                      color: AppColors.accentTeal,
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "A U R A",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "AI EXPENSE TRACKER",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: ScreenUtils.fontTextSmaller,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 64),
              AnimatedBuilder(
                animation: Listenable.merge([_statusText, _errorText]),
                builder: (context, _) {
                  final errorText = _errorText.value;
                  final statusText = _statusText.value;

                  if (errorText == null) {
                    return SizedBox(
                      width: 220,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const SizedBox(
                              height: 3,
                              child: LinearProgressIndicator(
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            statusText,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 40),
                          SizedBox(height: ScreenUtils.spacingControl),
                          Text(
                            errorText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
                              context.goNamed('home');
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
