import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constant/app_colors.dart';
import '../../../widgets/chart_widgets.dart';
import '../../../widgets/frosted_card.dart';
import '../../../widgets/loading_overlay.dart';
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
                  const SizedBox(height: 16),
                  
                  if (insightsState.status == InsightsStatus.success && insightsState.reportMarkdown != null)
                    FrostedCard(
                      opacity: 0.1,
                      child: SelectableText(
                        insightsState.reportMarkdown!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.5,
                        ),
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
