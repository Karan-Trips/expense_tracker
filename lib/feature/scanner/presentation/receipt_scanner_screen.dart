import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_constants.dart';
import '../../../widgets/frosted_card.dart';
import '../../../widgets/loading_overlay.dart';
import '../../expense/domain/expense.dart';
import 'scanner_viewmodel.dart';

class ReceiptScannerScreen extends ConsumerWidget {
  const ReceiptScannerScreen({super.key});

  void _onScanSuccess(BuildContext context, Map<String, dynamic> data) {
    // Parse merchant title
    final String merchant = data['merchant'] ?? "Unknown Merchant";

    // Parse amount safely
    double amount = 0.00;
    if (data['amount'] != null) {
      amount = double.tryParse(data['amount'].toString()) ?? 0.00;
    }

    // Parse date safely
    DateTime parsedDate = DateTime.now();
    if (data['date'] != null) {
      try {
        parsedDate = DateTime.parse(data['date'].toString());
      } catch (_) {}
    }

    // Parse category
    ExpenseCategory category = ExpenseCategory.others;
    if (data['category'] != null) {
      final catStr = data['category'].toString().toLowerCase().trim();
      category = ExpenseCategory.values.firstWhere(
        (c) => c.name == catStr,
        orElse: () => ExpenseCategory.others,
      );
    }

    // Parse description
    final String? description = data['description'];

    // Create a draft expense
    final draftExpense = Expense(
      id: '', // Blank represents new item draft
      title: merchant,
      amount: amount,
      date: parsedDate,
      categoryIndex: category.index,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Show warning snackbar if fallback data was generated
    if (data['isFallback'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Offline/Free Tier limit reached. We pre-filled draft details from the image for you!",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            backgroundColor: AppColors.accentPurple,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }

    // Navigate to AddEdit screen with pre-filled details
    context.push('/add-expense', extra: draftExpense);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scannerProvider);
    final notifier = ref.read(scannerProvider.notifier);

    // Listen for success status to navigate
    ref.listen<ScannerState>(scannerProvider, (previous, next) {
      if (next.status == ScanStatus.success && next.extractedData != null) {
        _onScanSuccess(context, next.extractedData!);
        notifier.reset(); // Reset to idle state after navigation
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("AI Receipt Scanner")),
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
                    "Quick Entry with Gemini AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Take a picture of any receipt or upload it from your gallery. Gemini will extract the details for you to verify.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Gemini Free Tier Rate Limit Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentTeal.withOpacity(0.24), width: 1.2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accentTeal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Gemini AI Free Tier Limit Notice",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Free tier is limited to 15 requests per minute. If you exceed this rate or are offline, scanning will gracefully fall back to pre-filled draft values so you never lose your flow.",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Image Display Area
                  if (scanState.imagePath != null)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Image.file(
                              File(scanState.imagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: notifier.reset,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                label: const Text(
                                  "Clear Image",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ),
                             SizedBox(width: ScreenUtils.margin),
                             Expanded(
                               child: ElevatedButton.icon(
                                 onPressed: () => notifier.scanReceipt(),
                                 icon: const Icon(Icons.auto_awesome),
                                 label: const Text("Scan Receipt"),
                               ),
                             ),
                           ],
                         ),
                       ],
                     )
                   else
                     // Selection Options (Solid Border Upload Area)
                     Container(
                       padding: EdgeInsets.symmetric(
                         vertical: ScreenUtils.keyboardRadius,
                         horizontal: ScreenUtils.fontTextMBig,
                       ),
                       decoration: BoxDecoration(
                         color: AppColors.surface.withOpacity(0.4),
                         borderRadius: BorderRadius.circular(ScreenUtils.margin),
                         border: Border.all(color: AppColors.border, width: 1.5),
                       ),
                       child: Column(
                         children: [
                           Container(
                             padding: EdgeInsets.all(ScreenUtils.margin),
                             decoration: BoxDecoration(
                               color: AppColors.accentTeal.withOpacity(0.1),
                               shape: BoxShape.circle,
                             ),
                             child: const Icon(
                               Icons.cloud_upload_outlined,
                               size: 48,
                               color: AppColors.accentTeal,
                             ),
                           ),
                           SizedBox(height: ScreenUtils.fontTextMBig),
                           Text(
                             "Upload Receipt Image",
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: ScreenUtils.fontText,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           const SizedBox(height: 6),
                           Text(
                             "Select receipt source to begin the AI scan",
                             style: TextStyle(
                               color: AppColors.textSecondary,
                               fontSize: ScreenUtils.fontTextSmaller,
                             ),
                           ),
                           const SizedBox(height: 28),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                             children: [
                               _buildSourceButton(
                                 icon: Icons.camera_alt,
                                 label: "Camera",
                                 onTap: () =>
                                     notifier.pickImage(ImageSource.camera),
                               ),
                               _buildSourceButton(
                                 icon: Icons.photo_library,
                                 label: "Gallery",
                                 onTap: () =>
                                     notifier.pickImage(ImageSource.gallery),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),

                  if (scanState.status == ScanStatus.error &&
                      scanState.errorMessage != null) ...[
                    const SizedBox(height: 24),
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
                                "Scanning Failed",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            scanState.errorMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Full screen loading indicator
          if (scanState.status == ScanStatus.scanning)
            const LoadingOverlay(
              message: "Gemini is analyzing your receipt...",
            ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.accentTeal),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


