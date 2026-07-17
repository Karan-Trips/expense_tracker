import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/locator/locator.dart';
import '../../expense/domain/expense.dart';

import '../../../core/constant/app_constants.dart';

enum InsightsStatus { idle, generating, success, error }

class InsightsState {
  final InsightsStatus status;
  final String? reportMarkdown;
  final String? errorMessage;

  InsightsState({
    required this.status,
    this.reportMarkdown,
    this.errorMessage,
  });

  InsightsState copyWith({
    InsightsStatus? status,
    String? reportMarkdown,
    String? errorMessage,
  }) {
    return InsightsState(
      status: status ?? this.status,
      reportMarkdown: reportMarkdown ?? this.reportMarkdown,
      errorMessage: errorMessage,
    );
  }
}

class InsightsViewModel extends StateNotifier<InsightsState> {
  final GeminiService _geminiClient;

  InsightsViewModel(this._geminiClient) : super(InsightsState(status: InsightsStatus.idle));

  Future<void> generateInsights(List<Expense> expenses) async {
    if (expenses.isEmpty) {
      state = state.copyWith(
        status: InsightsStatus.success,
        reportMarkdown: "No expense data available yet. Add some expenses to get AI-powered insights!",
      );
      return;
    }

    state = state.copyWith(status: InsightsStatus.generating);
    try {
      final List<Map<String, dynamic>> mappedList = expenses.map((e) => {
        'title': e.title,
        'amount': e.amount,
        'date': e.date.toIso8601String().split('T')[0],
        'category': AppConstants.getCategoryName(e.category),
        'description': e.description ?? '',
      }).toList();

      final jsonStr = jsonEncode(mappedList);
      final report = await _geminiClient.generateSpendingInsights(jsonStr);
      state = state.copyWith(status: InsightsStatus.success, reportMarkdown: report);
    } catch (e) {
      state = state.copyWith(status: InsightsStatus.error, errorMessage: e.toString());
    }
  }
}

final insightsProvider = StateNotifierProvider.autoDispose<InsightsViewModel, InsightsState>((ref) {
  return InsightsViewModel(locator<GeminiService>());
});
