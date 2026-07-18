import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constant/app_colors.dart';
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
    
    final expenses = expenseState.expenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Spending Insights"),
      ),
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
                        onPressed: () {
                          ref.read(insightsProvider.notifier).generateInsights(expenses);
                        },
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text("Generate"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentPurple.withOpacity(0.24), width: 1.2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accentPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Gemini AI Free Tier Limit Notice",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "Free tier allows 15 RPM (Requests Per Minute). If you see rate limit errors, please wait 30 seconds and try generating again.",
                                style: TextStyle(
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
                  
                  if (insightsState.status == InsightsStatus.success && insightsState.reportMarkdown != null)
                    FrostedCard(
                      opacity: 0.1,
                      child: MarkdownReportViewer(
                        markdown: insightsState.reportMarkdown!,
                      ),
                    )
                  else if (insightsState.status == InsightsStatus.error && insightsState.errorMessage != null)
                    FrostedCard(
                      borderColor: Colors.redAccent.withOpacity(0.4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
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
                            insightsState.errorMessage!,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
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
            const LoadingOverlay(message: "Gemini is analyzing your transactions..."),
        ],
      ),
    );
  }
}
