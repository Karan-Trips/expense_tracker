#
 🌌 Aura: AI-Powered Personal Expense Tracker

Aura is a premium, local-first personal finance tracker built using Flutter. Empowered by the Gemini AI API, Aura goes beyond simple tracking by scanning receipt images, generating strategic wealth-management advice, and providing high-fidelity visual representations of spending behavior.

---

## ✨ Features

- 📷 AI-Powered Receipt Scanner: Snap a picture or upload from your gallery. Aura uses Gemini 1.5 Flash as a high-precision OCR engine to extract the vendor name, total transaction value, date, category, and line-item descriptions in seconds.
- 📊 Elite AI Spending Insights: Get personalized wealth-building strategies, budgeting audits (e.g., 50/30/20 rule), and gamified savings challenges generated dynamically by Aura, your elite AI Wealth Management Consultant.
- 📈 Data Visualization: Track and visualize your spending habits over time with interactive, premium, glassmorphism-themed financial charts powered by `fl_chart` and `syncfusion_flutter_charts`.
- 🔒 Local-First & Offline Resilience: All transactions are stored locally using `hive_ce` (Community Edition Hive). The OCR scanner gracefully falls back to pre-filled draft values if you are offline or if your API limit is exceeded.
- ⚡ Hot-Reloadable API Configuration: Built-in dynamic service monitoring automatically detects changes to your `.env` configuration file and refreshes the AI engine on the fly without needing app rebuilds.

---

## 🛠️ Tech Stack & Architecture

Aura is built on professional, robust, and clean development paradigms:

* Framework: Flutter SDK (v3.11.0+)
* State Management: Riverpod (Decoupled MVVM architectural pattern)
* Dependency Injection: GetIt (Service locator injection)
* Local Storage: Hive CE (High-performance NoSQL local storage)
* Routing & Navigation: GoRouter (Declarative, path-based routing)
* AI Engine: Google Generative AI SDK (Gemini 1.5 Flash)
* Environment Configuration: Flutter DotEnv

Directory Structure

The project implements a feature-first clean architecture:

```text
lib/
├── core/
│   ├── constant/      # Design tokens, color palettes, spacing utilities
│   ├── error/         # Standardized failure and exception classes
│   ├── locator/       # GetIt dependency injection setup
│   ├── router/        # GoRouter navigation paths
│   └── services/      # Core engines (Gemini AI service, Hive Database)
├── feature/
│   ├── expense/       # Expense tracking (Data, Domain, Presentation/MVVM)
│   ├── home_main/     # Dashboard and core shell navigation layout
│   ├── insights/      # AI Wealth advisory reports and charts
│   ├── scanner/       # Receipt imaging, picking, and AI parsing ViewModel
│   └── splash/        # Pre-flight checklist & environment bootstrap screen
└── widgets/           # Global reusable UI widgets (glassmorphism cards, etc.)
```

---

## 🚀 Getting Started

📋 Prerequisites

Before running the application, make sure you have:
1. The Flutter SDK installed and configured on your machine.
2. A Gemini API Key (you can generate one for free on Google AI Studio).

---

⚙️ Setup & Configuration

1. Clone the repository:
   ```bash
   git clone https://github.com/Karan-Trips/expense_tracker.git
   cd expense_tracker
   ```

2. Create the environment file:
   In the root directory of the project, create a file named `.env` (or update the existing one):
   ```ini
   # Enter your Gemini API Key here:
   GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE
   ```

3. Incorporate Assets:
   Ensure the `.env` file is declared under the assets section in your `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - .env
   ```

---

🏃 Running the Application

1. Clear build cache and resolve dependencies (highly recommended to ensure your `.env` asset is cleanly packed):
   ```bash
   flutter clean
   ```

2. Fetch all required plugins and assets:
   ```bash
   flutter pub get
   ```

3. Run the code generation tools (for Hive adapters):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Launch the application on your connected emulator or physical device:
   ```bash
   flutter run
   ```

5. Build the production release APK (Android):
   ```bash
   flutter build apk --release
   ```

---

## ⚠️ Troubleshooting

Quota Exceeded (HTTP 429) / Rate Limits
The Gemini Free Tier is limited to 15 requests per minute. If you hit this limit:
- The receipt scanner will automatically switch to Offline Fallback Mode, generating draft values so you do not lose your scan history.
- Simply wait 60 seconds, or update `GEMINI_API_KEY` in `.env` with a fresh key. Due to Aura's dynamic key listener, the service will detect and apply the new key on your next scan attempt without needing to rebuild!

Changes to `.env` not appearing in the App
Flutter caches assets during the build process. If you update the `.env` file and hot reload is not picking up the new key:
1. Terminate the running session.
2. Run `flutter clean`.
3. Re-run `flutter run` or rebuild the release APK.
