# 🏏 CricScore

A modern, light, and elegant cricket scoring application built with Flutter, Firebase, and CricAPI. CricScore delivers live international match updates, upcoming series schedules, and a real-time local match scoring hub.

---

## ✨ Features

- **🔴 Live International Matches Dashboard**:
  - Real-time live scores, upcoming fixtures, and recent results via CricAPI.
  - Team flags and country badges with high-fidelity emoji fallbacks.
  - Category filters: *All Matches*, *Live*, *Upcoming*, and *Results*.
  - Search by team, tournament, or venue.

- **🏆 Cricket Series & Tours**:
  - Comprehensive series schedule with start and end dates.
  - Format badges: T20, ODI, Test, and Squad counts.
  - Automatic multi-flag extraction for bilateral tours and tournaments.

- **⚡ Local Match Scoring Hub**:
  - **Create Match**: Configure teams, squad lists, and match overs (2, 5, 10, 20, 50).
  - **Live Umpire Console**: Record runs (0, 1, 2, 3, 4, 6), boundaries, wickets, no-balls, wides, and undo actions.
  - **Ball-by-Ball Feed**: Chronological delivery commentary timeline automatically recorded.
  - **Spectator Mode**: Enter a 6-digit match code to watch local matches stream live in real time via Cloud Firestore.

- **🎨 Modern Light Cricket Theme**:
  - Cricket ground green (`#2E7D32`), soft accent green (`#66BB6A`), and light pitch background (`#F7FAF7`).
  - Dark forest green typography (`#1B2A1F`) with muted secondary accents (`#718078`).
  - Subtle borders (`#E3EBE4`), gold highlights (`#D9A441`), and live red indicators (`#E53935`).

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK `>=3.4.3 <4.0.0`)
- **Backend / Realtime Database**: [Firebase Cloud Firestore](https://firebase.google.com)
- **Live Cricket Data**: [CricAPI](https://cricapi.com)
- **Configuration & Security**: `flutter_dotenv` with `.env`

---

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/shivdattvanmane/cricscore.git
cd cricscore
```

### 2. Configure Environment Variables
Copy the example environment template:
```bash
cp .env.example .env
```
Open `.env` and fill in your CricAPI keys and Firebase credentials:
```env
CRICAPI_MATCH_KEY=your_cricapi_match_key_here
CRICAPI_SERIES_KEY=your_cricapi_series_key_here
FIREBASE_PROJECT_ID=your_firebase_project_id
...
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the Application
```bash
# Run on Web
flutter run -d chrome

# Run on Android / iOS / Desktop
flutter run
```

---

## 📂 Project Structure

```text
lib/
├── app_config.dart                  # Centralized .env configuration loader
├── cricd.dart                       # Local match creation & squad setup
├── cricket_series_model.dart        # Model for series & tour data
├── fetch_series.dart                # CricAPI series fetch service
├── firebase_options.dart            # Multi-platform Firebase configuration
├── flag_helper.dart                 # Country flags & team logo helper
├── global.dart                      # Global definitions
├── international_matches_screen.dart# International live dashboard
├── join.dart                        # Spectator view & live ball-by-ball commentary
├── main.dart                        # Application entry point & theme init
├── main_navigation_screen.dart      # 3-tab bottom navigation
├── matchcode.dart                   # 6-digit match code generator
├── MorePage.dart                    # Local match hub (Create, Join, Live Firestore feed)
├── series_list_screen.dart          # Series and tournament calendar
├── splashscreen.dart                # Light branded splash screen
├── theme.dart                       # Modern Light Cricket Design System
└── umpire.dart                      # Interactive live scoring console
```

---

## 🔒 Security
Sensitive API keys and secrets are stored in `.env`, which is strictly excluded from version control via `.gitignore`. Never commit `.env` to public repositories.

---

## 📄 License
This project is for educational and personal use.
