import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/services/gemini_limit_provider.dart';
import '../../../widgets/chart_widgets.dart';
import '../../../widgets/frosted_card.dart';
import '../../../widgets/loading_overlay.dart';
import '../../../widgets/markdown_report_viewer.dart';
import '../../expense/presentation/expense_viewmodel.dart';
import 'insights_viewmodel.dart';

class SpendingInsightsScreen extends ConsumerWidget {
  const SpendingInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseState = ref.watch(expenseProvider);
    final insightsState = ref.watch(insightsProvider);
    final limitState = ref.watch(geminiLimitProvider);

    final expenses = expenseState.expenses;

    return Scaffold(
      appBar: AppBar(title: const Text("AI Spending Insights")),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.background, Color(0xFF0D0D1F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  const Text(
                    "Monthly Trend",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Monthly bar chart
                  FrostedCard(
                    padding: const EdgeInsets.all(16),
                    child: MonthlyBarChart(expenses: expenses),
                  ),
                  const SizedBox(height: 28),

                  // Report Area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "AI Financial Report",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 36),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(insightsProvider.notifier)
                              .generateInsights(expenses);
                        },
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text("Generate"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentPurple.withOpacity(0.24),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.accentPurple,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Gemini AI Free Tier Limit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Out of 15 requests: ${limitState.remainingRequests} left",
                                    style: TextStyle(
                                      color: limitState.remainingRequests < 5
                                          ? Colors.orangeAccent
                                          : AppColors.accentPurple,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: limitState.remainingRequests / 15.0,
                                  backgroundColor: AppColors.border.withOpacity(
                                    0.4,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    limitState.remainingRequests < 5
                                        ? Colors.orangeAccent
                                        : AppColors.accentPurple,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                limitState.nextResetSeconds > 0
                                    ? "Next request slot resets in ${limitState.nextResetSeconds}s. If you hit the limit, please wait a minute before retrying."
                                    : "All 15 request slots are available. Generate spending insights reports dynamically.",
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (insightsState.status == InsightsStatus.success &&
                      insightsState.reportMarkdown != null) ...[
                    FrostedCard(
                      opacity: 0.1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Custom Action Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Custom Aura Chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentTeal.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.accentTeal.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.verified_user_rounded,
                                      size: 11,
                                      color: AppColors.accentTeal,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Aura Verified",
                                      style: TextStyle(
                                        color: AppColors.accentTeal,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Custom Download Button
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.accentPurple,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: AppColors.accentPurple.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  backgroundColor: AppColors.accentPurple.withOpacity(0.06),
                                ),
                                onPressed: () async {
                                  final path = await ref
                                      .read(insightsProvider.notifier)
                                      .saveReportToFile(
                                        insightsState.reportMarkdown!,
                                      );
                                  if (context.mounted && path.isNotEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Report saved to Documents: ${path.split('/').last}",
                                        ),
                                        backgroundColor: AppColors.accentPurple,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.download_rounded,
                                  size: 13,
                                ),
                                label: const Text(
                                  "Download",
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          MarkdownReportViewer(
                            markdown: insightsState.reportMarkdown ?? "",
                          ),
                        ],
                      ),
                    ),
                  ]
                  else if (insightsState.status == InsightsStatus.error &&
                      insightsState.errorMessage != null)
                    FrostedCard(
                      borderColor: Colors.redAccent.withOpacity(0.4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Failed to Generate Insights",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            insightsState.errorMessage ??
                                "An unknown error occurred.",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Default Greeting
                    FrostedCard(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.psychology,
                            size: 48,
                            color: AppColors.accentPurple,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Get AI Spending Patterns & Tips",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Click 'Generate' to let Gemini scan your transactions and write a personalized report containing spending tips, category ratios, and budget advice.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (insightsState.status == InsightsStatus.generating)
            const LoadingOverlay(
              message: "Gemini is analyzing your transactions...",
            ),
        ],
      ),
    );
  }
}
