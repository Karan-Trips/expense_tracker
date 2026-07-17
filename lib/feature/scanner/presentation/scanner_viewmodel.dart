import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/gemini_client.dart';
import '../../../core/locator/locator.dart';

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

class ScannerViewModel extends StateNotifier<ScannerState> {
  final GeminiClient _geminiClient;
  final ImagePicker _picker = ImagePicker();

  ScannerViewModel(this._geminiClient) : super(ScannerState(status: ScanStatus.idle));

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
      state = state.copyWith(status: ScanStatus.error, errorMessage: 'Failed to select image: ${e.toString()}');
    }
  }

  Future<void> scanReceipt() async {
    final bytes = state.imageBytes;
    if (bytes == null) {
      state = state.copyWith(status: ScanStatus.error, errorMessage: 'No image selected.');
      return;
    }

    state = state.copyWith(status: ScanStatus.scanning);
    try {
      final mimeType = state.imagePath?.endsWith('.png') == true ? 'image/png' : 'image/jpeg';
      final result = await _geminiClient.scanReceipt(bytes, mimeType);
      state = state.copyWith(status: ScanStatus.success, extractedData: result);
    } catch (e) {
      state = state.copyWith(status: ScanStatus.error, errorMessage: e.toString());
    }
  }

  void reset() {
    state = ScannerState(status: ScanStatus.idle);
  }
}

final scannerProvider = StateNotifierProvider.autoDispose<ScannerViewModel, ScannerState>((ref) {
  return ScannerViewModel(locator<GeminiClient>());
});
