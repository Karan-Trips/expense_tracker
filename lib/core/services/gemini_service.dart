import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../error/failures.dart';

class GeminiService {
  late final GenerativeModel _visionModel;
  late final GenerativeModel _textModel;
  bool _isInitialized = false;

  void init() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw const UnknownFailure(
          'Gemini API Key is missing in the .env file. Please define GEMINI_API_KEY.',
        );
      }

      _visionModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'merchant': Schema.string(
                description: 'Name of the merchant, store, or vendor',
              ),
              'amount': Schema.number(
                description: 'Grand total spending amount paid as a double',
              ),
              'date': Schema.string(
                description: 'Transaction date in YYYY-MM-DD format',
              ),
              'category': Schema.string(
                description:
                    'Must match exactly one of: food, shopping, travel, utilities, entertainment, others',
              ),
              'description': Schema.string(
                description: 'Brief description of items bought in 4-8 words',
              ),
            },
            requiredProperties: [
              'merchant',
              'amount',
              'date',
              'category',
              'description',
            ],
          ),
        ),
        systemInstruction: Content.system(
          'You are a high-precision OCR transaction scanner. Extract the merchant name, total paid amount, date, closest category, and a description. Return JSON strictly conforming to the requested schema. If details are blurry or missing, infer them logically.',
        ),
      );

      _textModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'You are Aura, an elite AI Wealth Management Consultant. Your tone is motivating, strategic, and highly professional. You analyze transaction logs in Indian Rupees (INR) and deliver wealth-building strategies.',
        ),
      );

      _isInitialized = true;
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(
        'Failed to initialize Gemini Client: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> scanReceipt(
    Uint8List imageBytes,
    String mimeType,
  ) async {
    if (!_isInitialized) init();

    const prompt = '''
    You are an elite, high-precision OCR transaction scanner. Your goal is to analyze the receipt image and extract the key details with 100% accuracy.
    Return ONLY a raw JSON object matching the requested schema.

    Here are advanced rules to handle messy or complex receipt types:
    1. **Merchant Name**:
       - Scan the very top of the receipt. Look for brand logos, trading names, or branch headers (e.g. "D-Mart", "Starbucks", "Reliance Retail").
       - Ignore generic document headers like "Tax Invoice", "Cash Memo", "Receipt", or "Invoice".
       - If the main name is faded, look at the email, website URL, or bottom copyright text for a merchant name clue (e.g. info@bluetokai.com -> "Blue Tokai").
    2. **Transaction Amount**:
       - Look for words like "TOTAL", "GRAND TOTAL", "NET AMOUNT", "AMOUNT PAID", "CASH DUE", "PAID VIA CARD".
       - In GST / Indian receipts, ignore tax breakdown totals (CGST, SGST, round-offs) and extract the final bottom-most payable figure.
       - Clean all currency symbols (₹, Rs., INR) and commas. Parse the amount strictly as a double (e.g., 254.50).
    3. **Transaction Date**:
       - Locate the date string. It can be formatted as DD/MM/YYYY, DD-MM-YYYY, YYYY/MM/DD, or DD-MMM-YYYY (e.g. "18-Jul-2026").
       - Normalize the extracted date into standard "YYYY-MM-DD" format.
       - If the date is not present, blurry, or missing, fall back to today's date in YYYY-MM-DD.
    4. **Smart Category Classification**:
       - 'food': restaurants, bars, groceries, coffee shops, bakeries, food delivery apps (Zomato/Swiggy).
       - 'shopping': clothing stores, electronics, department stores, general merchandise (Amazon, Flipkart).
       - 'travel': fuel stations, taxis, Uber/Ola, flights, train tickets, tolls.
       - 'utilities': mobile recharges, electricity boards, broadband, piped gas, water bills.
       - 'entertainment': multiplexes, OTT subscriptions, concerts, theme parks, gaming zones.
       - 'others': use only if the items don't map to any of the above.
    5. **Item-Specific Description**:
       - Scan the individual line-item list.
       - Synthesize a descriptive summary of what was purchased (e.g. "2x Cappuccino & Croissant" or "Weekly Grocery: Milk, Bread, Eggs" or "Zara Winter Jacket").
       - Keep it concise (4-8 words) but specific to what is listed in the image.
    ''';

    try {
      final content = [
        Content.multi([DataPart(mimeType, imageBytes), TextPart(prompt)]),
      ];

      final response = await _visionModel.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        throw const AIFailure('Empty response received from Gemini.');
      }

      var cleanedText = responseText.trim();
      if (cleanedText.startsWith('```')) {
        final lines = cleanedText.split('\n');
        if (lines.first.startsWith('```')) {
          lines.removeAt(0);
        }
        if (lines.isNotEmpty && lines.last.startsWith('```')) {
          lines.removeLast();
        }
        cleanedText = lines.join('\n').trim();
      }

      final parsed = jsonDecode(cleanedText);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
      throw const AIFailure('Gemini output could not be parsed as a JSON map.');
    } on SocketException catch (_) {
      throw const NetworkFailure(
        'No internet connection detected. Please check your connectivity and try again.',
      );
    } catch (e) {
      if (e is Failure) rethrow;
      final errStr = e.toString();
      if (errStr.contains('SocketException') ||
          errStr.contains('Network') ||
          errStr.contains('HandshakeException') ||
          errStr.contains('Failed host lookup')) {
        throw const NetworkFailure(
          'No internet connection detected. Please check your connectivity and try again.',
        );
      }
      throw AIFailure('Receipt scanning failed: $errStr');
    }
  }

  Future<String> generateSpendingInsights(String expensesJson) async {
    if (!_isInitialized) init();

    final prompt =
        '''
    You are an expert AI Personal Finance Planner. All currency amounts are in Indian Rupees (INR).
    Analyze the following list of transactions (provided in JSON format) and write a professional, engaging, and highly structured spending report. Use the Indian Rupee symbol (₹) for all currency displays.

    Transactions:
    $expensesJson

    Your report MUST contain these four clearly marked Markdown sections:

    ### 📊 Spending Analysis & Run-Rate Projections
    - State the total spent, transaction count, and the single largest transaction (with merchant name).
    - Provide a breakdown of category ratios (e.g., Shopping vs. Food). Highlight areas where the user is overspending.
    - **Run-Rate Projection**: Estimate their month-end total spending based on their current transaction frequency and velocity, advising if they are on track to exceed their baseline budget.

    ### 💰 Savings Strategy (What to Save)
    - Provide concrete recommendations on how much of their budget/income they should target to save.
    - Suggest building an emergency fund (e.g., targeting 3-6 months of their typical spending baseline).
    - Detail specific savings goals based on their current spending behaviors.

    ### 🛡️ Money Management Advice (How to Manage)
    - Give actionable tips on how they can better structure and track their monthly cash flow.
    - Recommend budgeting frameworks (like the 50/30/20 rule: 50% Needs, 30% Wants, 20% Savings) customized to their transaction baseline.
    - Detail 2-3 specific rules they should enforce next month (e.g. setting custom category caps, shopping list delays).

    ### 🎯 Wealth Building Challenges & Action Items
    - Create a gamified weekly savings challenge (e.g. "The 7-Day No-Shopping Challenge" or "Brew-Your-Own-Coffee week") designed around their highest category.
    - Suggest specific automation triggers (e.g. "Set up an automatic transfer of ₹500 to your savings account right after salary credit").

    Format the entire response in beautiful, clean Markdown. Use bold headers, bullet lists, and highlight key figures for readability. Do not mention dollars (\$); always use Rupees (₹).
    ''';

    try {
      final response = await _textModel.generateContent([Content.text(prompt)]);
      return response.text ??
          'Unable to generate report insights at this time.';
    } on SocketException catch (_) {
      throw const NetworkFailure(
        'No internet connection detected. Please check your connectivity and try again.',
      );
    } catch (e) {
      if (e is Failure) rethrow;
      final errStr = e.toString();
      if (errStr.contains('SocketException') ||
          errStr.contains('Network') ||
          errStr.contains('HandshakeException') ||
          errStr.contains('Failed host lookup')) {
        throw const NetworkFailure(
          'No internet connection detected. Please check your connectivity and try again.',
        );
      }
      throw AIFailure('Failed to generate spending insights: $errStr');
    }
  }
}
