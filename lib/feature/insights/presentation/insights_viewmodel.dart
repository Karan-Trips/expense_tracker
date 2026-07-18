import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/locator/locator.dart';
import '../../../core/services/gemini_limit_provider.dart';
import '../../../core/services/notification_service.dart';
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

class InsightsViewModel extends AutoDisposeNotifier<InsightsState> {
  late final GeminiService _geminiService;

  @override
  InsightsState build() {
    _geminiService = locator<GeminiService>();
    return InsightsState(status: InsightsStatus.idle);
  }

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
      ref.read(geminiLimitProvider.notifier).registerRequest();
      final report = await _geminiService.generateSpendingInsights(jsonStr);
      state = state.copyWith(status: InsightsStatus.success, reportMarkdown: report);
      
      // Auto save and notify user
      await saveReportToFile(report);
    } catch (e) {
      final errStr = e.toString();
      String userFriendlyError = errStr;
      
      if (errStr.contains('429') || errStr.contains('RESOURCE_EXHAUSTED') || errStr.contains('Quota exceeded')) {
        userFriendlyError = "Gemini Free Tier limit (15 requests per minute) has been reached! Please wait a minute, or update/change the GEMINI_API_KEY in your .env file to continue.";
      } else if (errStr.contains('403') || errStr.contains('API_KEY_INVALID') || errStr.contains('API key')) {
        userFriendlyError = "Invalid Gemini API Key! Please verify or replace the GEMINI_API_KEY inside your .env file at the project root.";
      }
      
      state = state.copyWith(status: InsightsStatus.error, errorMessage: userFriendlyError);
    }
  }

  Future<String> saveReportToFile(String reportText) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dateStr = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/Aura_Spending_Insights_$dateStr.md');
      await file.writeAsString(reportText);

      // Trigger local notification
      await NotificationService.showNotification(
        id: 100,
        title: "Insights Report Saved!",
        body: "File saved: ${file.path.split('/').last}",
      );
      return file.path;
    } catch (e) {
      return '';
    }
  }
}

final insightsProvider = AutoDisposeNotifierProvider<InsightsViewModel, InsightsState>(InsightsViewModel.new);
