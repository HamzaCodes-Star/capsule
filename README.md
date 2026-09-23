# C A P S U L E

> **The Intelligent AI Capsule Wardrobe & Daily Stylist**  
> *Cross-Platform Flutter Mobile Application (iOS & Android)*

![Flutter](https://img.shields.io/badge/Flutter-3.29+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart&logoColor=white)
![AI Vision](https://img.shields.io/badge/Vision_AI-Gemini_Flash-8E75C2?logo=google&logoColor=white)
![License](https://img.shields.io/badge/License-Proprietary-gold)

---

## 👔 Overview

**Capsule** is an AI-powered menswear and minimalist wardrobe assistant built with Flutter. It eliminates decision fatigue by curating weather-smart, color-harmonized daily outfits from a minimal set of versatile pieces.

Unlike generic closet organizers, **Capsule** runs a **deterministic on-device color science engine** (<10ms execution, zero cloud tokens) paired with **Google Gemini Vision** for single flat-lay bed-spread clothing batch ingestion.

---

## 🌟 Key Features

### 1. ⚡ Deterministic Daily Stylist Engine
- **Real-Time Weather Awareness**: Dynamically adjusts recommendations based on temperature brackets (Freezing, Cold, Mild, Hot) and rain status.
- **Rain Protection**: Automatically restricts delicate materials (e.g., suede loafers, espadrilles) during precipitation.
- **Formality Tier Matching**: Enforces style guardrails across **Casual (Tier 1)**, **Smart Casual (Tier 2)**, and **Business / Tailored (Tier 3)**.
- **Interactive Lock & Shuffle**: Lock a favorite piece (e.g., your linen shirt or selvedge denim) and shuffle through harmonizing combinations around it.

### 2. 🎨 Algorithmic Color Science (HSL Harmony)
- **Neutral Anchors**: Pairs core neutral bases (White, Navy, Khaki, Charcoal, Olive, Camel) with intentional lightness contrast.
- **Monochromatic Depth**: Evaluates tonal gradients with lightness deltas $\ge 25\%$.
- **Complementary Contrast**: Pairs balanced opposite hues with controlled saturation to avoid harsh clashing.

### 3. 🧺 Wear-Cycle & Hamper Lifecycle Tracking
- **Automatic Hygiene Guardrails**:
  - Base layers (T-shirts, dress shirts): 1 wear $\rightarrow$ laundry hamper.
  - Trousers & Chinos: 3 wears $\rightarrow$ laundry hamper.
  - Raw Denim & Outerwear: 5–10 wears $\rightarrow$ laundry hamper.
- **1-Tap "Did Laundry"**: Clears all washed pieces back to clean vault status simultaneously.

### 4. 📸 Flat-Lay Bed-Spread Batch Ingestion (Gemini Vision)
- Photograph up to 5 garments laid flat on a bed or floor.
- Gemini 1.5/2.0 Flash automatically segments each piece, classifies category (Top, Bottom, Footwear, Outerwear), detects dominant HSL color hex codes, and recommends wear limits.
- Persisted locally to device storage (`path_provider`) for offline access.

### 5. 📖 Lookbook & Wardrobe Utilization Analytics
- Daily worn outfit history timeline.
- Capsule Utilization Metric tracking what percentage of pieces are actively rotating.

---

## 📱 App Store Optimization (ASO) Package

### App Store & Google Play Metadata
* **App Title**: `Capsule: AI Minimalist Wardrobe & Outfit Stylist`
* **App Subtitle / Short Description**: `Build your minimalist capsule wardrobe. Weather-smart outfits & laundry tracker.`
* **Category**: Lifestyle / Shopping & Fashion
* **Primary Target Keywords**:
  * `capsule wardrobe`
  * `outfit planner`
  * `minimalist closet`
  * `AI stylist`
  * `menswear style`
  * `outfit maker`
  * `closet organizer`
  * `color theory fashion`
  * `daily drip`

---

## 🏗️ Architecture & Technology Stack

```
capsule/
├── lib/
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   │   └── wardrobe_repository.dart       # Reactive state repository (ChangeNotifier)
│   │   └── services/
│   │       ├── database_service.dart          # SQLite (sqflite) offline-first database
│   │       └── vision_ingestion_service.dart  # Gemini Flash Vision REST client
│   ├── domain/
│   │   ├── models/
│   │   │   ├── garment.dart                   # Garment model, formality tiers, wear metrics
│   │   │   ├── matching_context.dart          # Weather bracket, temperature, rain flag
│   │   │   ├── outfit.dart                    # Outfit representation and harmony reason
│   │   │   └── outfit_log.dart                # Historical log representation
│   │   └── styling/
│   │       ├── color_science.dart             # HSL Euclidean color harmony algorithms
│   │       ├── hsl_color.dart                 # Custom HSL conversion utility
│   │       └── outfit_engine.dart             # Combinatorial search & constraint solver
│   └── ui/
│       ├── core/
│       │   └── theme/app_theme.dart           # Luxury Obsidian, Slate, & Camel design system
│       └── features/
│           ├── batch_capture/                 # Flat-lay bed-spread camera scanner
│           ├── daily_stylist/                 # Outfit recommendation, lock & shuffle
│           ├── lookbook/                      # Outfit history & wardrobe utilization
│           ├── navigation/                    # Persistent bottom navigation
│           ├── settings/                      # Gemini API key and capsule reset
│           └── wardrobe/                      # Wardrobe vault, filters, item detail sheets
└── test/
    ├── color_science_test.dart                # Color theory validation
    ├── outfit_engine_test.dart                # Formality & weather constraint tests
    ├── outfit_log_test.dart                   # Wear cycle and domain log tests
    └── widget_test.dart                       # App smoke test
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK 3.29.0 or newer
* Xcode 16+ (for iOS builds)
* Android Studio / Android SDK 34+ (for Android builds)

### Installation
```bash
# Clone the repository
git clone https://github.com/HamzaCodes-Star/capsule.git
cd capsule

# Install Flutter dependencies
flutter pub get

# Run static analysis
flutter analyze

# Execute test suite
flutter test

# Run on macOS / connected device
flutter run
```

---

## 🔒 Gemini API Configuration
To enable live AI vision scanning for clothing flat-lays:
1. Obtain an API key from [Google AI Studio](https://aistudio.google.com/).
2. Open **Capsule** $\rightarrow$ Navigate to **Settings**.
3. Paste your Gemini API key and tap **Save API Key**.
*(If no API key is provided, Capsule automatically activates high-fidelity deterministic offline simulation).*

---

© 2026 MAPMAC STUDIO PROJECTS. All rights reserved.
