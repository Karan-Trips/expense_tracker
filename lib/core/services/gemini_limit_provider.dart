import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeminiLimitState {
  final int maxRequests;
  final int remainingRequests;
  final List<DateTime> requestTimestamps;
  final int nextResetSeconds;

  GeminiLimitState({
    required this.maxRequests,
    required this.remainingRequests,
    required this.requestTimestamps,
    required this.nextResetSeconds,
  });

  GeminiLimitState copyWith({
    int? maxRequests,
    int? remainingRequests,
    List<DateTime>? requestTimestamps,
    int? nextResetSeconds,
  }) {
    return GeminiLimitState(
      maxRequests: maxRequests ?? this.maxRequests,
      remainingRequests: remainingRequests ?? this.remainingRequests,
      requestTimestamps: requestTimestamps ?? this.requestTimestamps,
      nextResetSeconds: nextResetSeconds ?? this.nextResetSeconds,
    );
  }
}

class GeminiLimitNotifier extends StateNotifier<GeminiLimitState> {
  Timer? _cleanupTimer;

  GeminiLimitNotifier()
      : super(GeminiLimitState(
          maxRequests: 15,
          remainingRequests: 15,
          requestTimestamps: [],
          nextResetSeconds: 0,
        )) {
    // Periodically prune expired requests every second to keep the UI in sync
    _cleanupTimer = Timer.periodic(const Duration(seconds: 1), (_) => _cleanupOldRequests());
  }

  void _cleanupOldRequests() {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    // Remove requests that occurred more than 60 seconds ago
    final updatedTimestamps = state.requestTimestamps.where((time) => time.isAfter(oneMinuteAgo)).toList();

    int nextReset = 0;
    if (updatedTimestamps.isNotEmpty) {
      final oldest = updatedTimestamps.first;
      final timePassed = now.difference(oldest);
      nextReset = (60 - timePassed.inSeconds).clamp(0, 60);
    }

    final remaining = 15 - updatedTimestamps.length;
    state = state.copyWith(
      requestTimestamps: updatedTimestamps,
      remainingRequests: remaining.clamp(0, 15),
      nextResetSeconds: nextReset,
    );
  }

  void registerRequest() {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    // Add new timestamp and prune expired ones
    final updatedTimestamps = [
      ...state.requestTimestamps.where((time) => time.isAfter(oneMinuteAgo)),
      now
    ];

    int nextReset = 0;
    if (updatedTimestamps.isNotEmpty) {
      final oldest = updatedTimestamps.first;
      final timePassed = now.difference(oldest);
      nextReset = (60 - timePassed.inSeconds).clamp(0, 60);
    }

    final remaining = 15 - updatedTimestamps.length;
    state = state.copyWith(
      requestTimestamps: updatedTimestamps,
      remainingRequests: remaining.clamp(0, 15),
      nextResetSeconds: nextReset,
    );
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }
}

final geminiLimitProvider = StateNotifierProvider<GeminiLimitNotifier, GeminiLimitState>((ref) {
  return GeminiLimitNotifier();
});
