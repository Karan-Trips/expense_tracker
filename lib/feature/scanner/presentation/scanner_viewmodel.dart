import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/locator/locator.dart';
import '../../../core/services/gemini_limit_provider.dart';

enum ScanStatus { idle, picking, scanning, success, error }

class ScannerState {
  final ScanStatus status;
  final String? imagePath;
  final Uint8List? imageBytes;
  final String? errorMessage;
  final Map<String, dynamic>? extractedData;

  ScannerState({
    required this.status,
    this.imagePath,
    this.imageBytes,
    this.errorMessage,
    this.extractedData,
  });

  ScannerState copyWith({
    ScanStatus? status,
    String? imagePath,
    Uint8List? imageBytes,
    String? errorMessage,
    Map<String, dynamic>? extractedData,
  }) {
    return ScannerState(
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      errorMessage: errorMessage,
      extractedData: extractedData ?? this.extractedData,
    );
  }
}

class ScannerViewModel extends AutoDisposeNotifier<ScannerState> {
  late final GeminiService _geminiService;
  final ImagePicker _picker = ImagePicker();

  @override
  ScannerState build() {
    _geminiService = locator<GeminiService>();
    return ScannerState(status: ScanStatus.idle);
  }

  Future<void> pickImage(ImageSource source) async {
    state = state.copyWith(status: ScanStatus.picking);
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) {
        state = state.copyWith(status: ScanStatus.idle);
        return;
      }
      final bytes = await file.readAsBytes();
      state = state.copyWith(
        status: ScanStatus.idle,
        imagePath: file.path,
        imageBytes: bytes,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Failed to select image: ${e.toString()}',
      );
    }
  }

  Future<void> scanReceipt() async {
    final bytes = state.imageBytes;
    if (bytes == null) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'No image selected.',
      );
      return;
    }

    state = state.copyWith(status: ScanStatus.scanning);
    try {
      final mimeType = state.imagePath?.endsWith('.png') == true
          ? 'image/png'
          : 'image/jpeg';
      ref.read(geminiLimitProvider.notifier).registerRequest();
      final result = await _geminiService.scanReceipt(bytes, mimeType);
      state = state.copyWith(status: ScanStatus.success, extractedData: result);
    } catch (e) {
      debugPrint('Error scanning receipt: $e');
      final errStr = e.toString();
      final bool isRateLimit =
          errStr.contains('429') ||
          errStr.contains('RESOURCE_EXHAUSTED') ||
          errStr.contains('Quota exceeded');
      final bool isInvalidKey =
          errStr.contains('403') ||
          errStr.contains('API_KEY_INVALID') ||
          errStr.contains('API key');

      // Graceful fallback to guarantee scanner works anyway
      final fallbackData = {
        'merchant': 'Scanned Vendor',
        'amount': 0.00,
        'date': DateTime.now().toIso8601String().split('T').first,
        'category': 'others',
        'description': 'AI offline/limit fallback. Please update manually.',
        'isFallback': true,
        'isRateLimit': isRateLimit,
        'isInvalidKey': isInvalidKey,
      };
      state = state.copyWith(
        status: ScanStatus.success,
        extractedData: fallbackData,
      );
    }
  }

  void reset() {
    state = ScannerState(status: ScanStatus.idle);
  }
}

final scannerProvider =
    AutoDisposeNotifierProvider<ScannerViewModel, ScannerState>(
      ScannerViewModel.new,
    );
