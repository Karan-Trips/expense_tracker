import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../error/failures.dart';

class GeminiClient {
  late final GenerativeModel _visionModel;
  late final GenerativeModel _textModel;
  bool _isInitialized = false;

  void init() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw const UnknownFailure('Gemini API Key is missing in the .env file. Please define GEMINI_API_KEY.');
      }
      
      // Using gemini-1.5-flash for speed and vision capabilities
      _visionModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );

      _textModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
      
      _isInitialized = true;
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure('Failed to initialize Gemini Client: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> scanReceipt(Uint8List imageBytes, String mimeType) async {
    if (!_isInitialized) init();

    const prompt = '''
    Analyze this receipt image and extract the following details. 
    Return ONLY a raw JSON object matching this structure:
    {
      "merchant": "Name of the merchant or store",
      "amount": 0.00,
      "date": "YYYY-MM-DD",
      "category": "One of: food, shopping, travel, utilities, entertainment, others",
      "description": "Short description of items bought"
    }

    Notes:
    - If the date is not found or unclear, use today's date in YYYY-MM-DD format.
    - Amount must be a double.
    - Category must match exactly one of the six lowercase categories specified. Do not invent new categories.
    - If unsure, use "others".
    ''';

    try {
      final content = [
        Content.multi([
          DataPart(mimeType, imageBytes),
          TextPart(prompt),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      final responseText = response.text;
      
      if (responseText == null || responseText.isEmpty) {
        throw const AIFailure('Empty response received from Gemini.');
      }

      // Safe JSON parsing
      final parsed = jsonDecode(responseText.trim());
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
      throw const AIFailure('Gemini output could not be parsed as a JSON map.');
    } catch (e) {
      throw AIFailure('Receipt scanning failed: ${e.toString()}');
    }
  }

  Future<String> generateSpendingInsights(String expensesJson) async {
    if (!_isInitialized) init();

    final prompt = '''
    You are an AI Personal Finance Assistant.
    Analyze the following list of transactions (provided in JSON format) and write a natural, engaging, and professional spending report.

    Transactions:
    $expensesJson

    Your report MUST include:
    1. Total spending amount and transaction count.
    2. A brief breakdown of categories and how much was spent in each.
    3. The largest single expense or merchant name.
    4. Trends and patterns you observe (e.g. eating out a lot, high shopping bills).
    5. At least one highly actionable, personalized recommendation (e.g. "You spent 35% more on food delivery this month compared to last month. Consider setting a monthly dining budget.").

    Format the response in beautiful, clean Markdown. Use bullet points and bold text for readability.
    ''';

    try {
      final response = await _textModel.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate report insights at this time.';
    } catch (e) {
      throw AIFailure('Failed to generate spending insights: ${e.toString()}');
    }
  }
}
