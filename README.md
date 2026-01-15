<div align="center">

# 🧠 BrainiumX

### *Train Your Mind, Track Your Progress*

**12 scientifically-designed cognitive games. Professional ELO rating system. Comprehensive brain training for the modern mind.**

[![Download on Google Play](https://img.shields.io/badge/Google_Play-414141?style=for-the-badge&logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=com.brainiumx.brain_game&hl=en_IN)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-00A8E8?style=flat&logo=flutter&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-FF6F00?style=flat&logo=hive&logoColor=white)

---

*"The mind is not a vessel to be filled, but a fire to be kindled." - Plutarch*

</div>

---

## 🎯 What is BrainiumX?

BrainiumX is a comprehensive brain training application that challenges your cognitive abilities through 12 carefully crafted games. Each game targets specific mental domains - from lightning-fast reaction times to complex problem-solving skills.

Unlike casual brain games, BrainiumX uses a professional **ELO rating system** (adapted from chess) to accurately track your cognitive performance over time. Watch your mental fitness improve as you train!

---

## 🎮 Cognitive Domains & Games

### ⚡ Speed & Attention
Test your reaction time and focus with rapid-fire challenges.

| Game | Description | Key Skills |
|------|-------------|------------|
| **Speed Tap** | Tap targets as fast as possible | Reaction time, hand-eye coordination |
| **Go/No-Go** | Respond to targets, ignore distractors | Impulse control, selective attention |
| **Focus Shift** | Switch between different task rules | Cognitive flexibility, task switching |

### 🧩 Memory
Challenge your working memory and recall abilities.

| Game | Description | Key Skills |
|------|-------------|------------|
| **Memory Grid** | Remember and recall visual patterns | Visual memory, spatial recall |
| **Pattern Sequence** | Reproduce increasingly complex sequences | Sequential memory, pattern recognition |

### 🔍 Problem Solving
Exercise your logical reasoning and strategic thinking.

| Game | Description | Key Skills |
|------|-------------|------------|
| **Arithmetic Sprint** | Solve math problems under time pressure | Mental arithmetic, processing speed |
| **Trail Connect** | Connect numbers and letters in sequence | Planning, visual scanning |
| **Spatial Rotation** | Identify rotated shapes | Spatial reasoning, mental rotation |

### 🎨 Mental Flexibility
Train your brain to adapt and switch between different mental tasks.

| Game | Description | Key Skills |
|------|-------------|------------|
| **Stroop Match** | Match colors while ignoring conflicting text | Interference control, selective attention |
| **Color Match** | Identify matching colors quickly | Visual processing, decision making |
| **Color Dominance** | Find the most frequent color in a grid | Visual analysis, counting |
| **Word Chain** | Build word associations under time pressure | Verbal fluency, semantic memory |

---

## ✨ Features

### 📊 Professional Performance Tracking
- **ELO Rating System**: Chess-inspired rating that adapts to your skill level
- **Detailed Statistics**: Track progress across all cognitive domains
- **Best Score Recording**: See your personal records for each game
- **Performance Graphs**: Visualize your improvement over time

### 🎯 Adaptive Difficulty
- **Three Difficulty Levels**: Easy, Medium, Hard for each game
- **Dynamic Challenges**: Games adjust complexity based on your performance
- **Progressive Training**: Start easy, master harder challenges

### 📚 Comprehensive Help System
- **Game Tutorials**: Learn how to play each game
- **Cognitive Science**: Understand what each game trains
- **ELO Explanation**: Learn how your rating is calculated
- **Strategy Tips**: Improve your performance with expert advice

### 🎨 Modern, Clean Interface
- **Material Design 3**: Beautiful, intuitive UI
- **Dark/Light Themes**: Choose your preferred visual style
- **Smooth Animations**: Polished, professional experience
- **Responsive Layout**: Works perfectly on all screen sizes

### 💾 Local Data Storage
- **Privacy First**: All data stored locally on your device
- **No Account Required**: Start playing immediately
- **Offline Support**: Train your brain anywhere, anytime
- **Data Export**: Share your progress (coming soon)

---

## 🏗️ Architecture

```
BrainiumX/
├── lib/
│   ├── core/
│   │   ├── base/              # Base game engine
│   │   ├── constants/         # App-wide constants
│   │   ├── providers/         # Riverpod state management
│   │   ├── services/          # Core services (data, error, performance)
│   │   ├── theme/             # Material Design 3 theming
│   │   ├── utils/             # Utilities (scoring, difficulty, RNG)
│   │   └── widgets/           # Reusable UI components
│   ├── data/
│   │   └── models/            # Hive data models
│   ├── features/
│   │   ├── games/             # 12 game implementations
│   │   ├── help/              # Help & tutorial screens
│   │   ├── home/              # Main dashboard
│   │   ├── legal/             # Privacy, terms, about
│   │   ├── onboarding/        # First-time user experience
│   │   ├── settings/          # App settings
│   │   └── splash/            # Splash screen
│   └── main.dart              # App entry point
├── android/                   # Android platform code
├── assets/                    # Images, icons, animations
└── test/                      # Unit & widget tests
```


---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.5.0 or higher
- Dart SDK 3.5.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android builds)

### Installation

```bash
# Clone the repository
git clone https://github.com/Khanna-Aman/BrainiumX.git
cd BrainiumX

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Building for Production

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle (for Google Play)
```bash
flutter build appbundle --release
```

The output files will be in:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## 🧪 Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

---

## 📱 Tech Stack

### Core Framework
- **Flutter 3.5+**: Cross-platform UI framework
- **Dart 3.5+**: Programming language

### State Management
- **Riverpod 2.5+**: Reactive state management
- **Provider Pattern**: Dependency injection

### Local Storage
- **Hive 2.2+**: Fast, lightweight NoSQL database
- **Hive Flutter**: Flutter integration for Hive
- **Shared Preferences**: Simple key-value storage

### UI/UX
- **Material Design 3**: Modern design system
- **Google Fonts**: Custom typography
- **FL Chart**: Beautiful data visualization
- **Go Router**: Declarative routing

### Development Tools
- **Build Runner**: Code generation
- **Hive Generator**: Model adapters
- **Flutter Lints**: Code quality
- **Flutter Launcher Icons**: App icon generation

---

## 🎯 How the ELO System Works

BrainiumX uses a modified ELO rating system (originally from chess) to track your cognitive performance:

### Initial Rating
- All players start at **1200 ELO**
- This represents average cognitive performance

### Rating Changes
- **Win (good performance)**: Rating increases
- **Loss (poor performance)**: Rating decreases
- **K-Factor**: Determines how much ratings change (32 for new players, 16 for experienced)

### Performance Calculation
Each game has its own scoring criteria:
- **Speed games**: Based on reaction time and accuracy
- **Memory games**: Based on recall accuracy and speed
- **Problem-solving**: Based on correct answers and time taken

### Rating Tiers
- 🥉 **Bronze** (< 1200): Beginner
- 🥈 **Silver** (1200-1400): Intermediate
- 🥇 **Gold** (1400-1600): Advanced
- 💎 **Diamond** (1600-1800): Expert
- 👑 **Master** (1800+): Elite

---

## 🔒 Privacy & Security

- **No Data Collection**: We don't collect any personal information
- **Local Storage Only**: All data stays on your device
- **No Ads**: Clean, distraction-free experience
- **No Tracking**: No analytics or third-party trackers
- **Open Source**: Code is transparent and auditable

---

## 🗺️ Roadmap

### Version 1.1 (Coming Soon)
- [ ] Cloud sync for progress backup
- [ ] Multiplayer challenges
- [ ] Daily brain training streaks
- [ ] Achievement system
- [ ] Custom training plans

### Version 1.2
- [ ] More games (15+ total)
- [ ] Advanced statistics and insights
- [ ] Social features (leaderboards, friends)
- [ ] Personalized difficulty adjustment
- [ ] Export progress reports

### Future Ideas
- [ ] AI-powered training recommendations
- [ ] Voice-controlled games
- [ ] Accessibility improvements
- [ ] iOS version
- [ ] Web version

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Development Guidelines
- Follow the existing code style
- Write tests for new features
- Update documentation as needed
- Keep commits atomic and well-described

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Chess.com** - Inspiration for the ELO rating system
- **Lumosity** - Cognitive game design principles
- **Material Design** - UI/UX guidelines
- **Flutter Community** - Amazing framework and support

---

## 📧 Contact

**Aman Khanna**
- GitHub: [@Khanna-Aman](https://github.com/Khanna-Aman)

---

<div align="center">

**Built with ❤️ and cognitive science**

Flutter • Dart • Riverpod • Hive • Material Design 3

⭐ Star this repo if BrainiumX helped sharpen your mind!

[Download on Google Play](https://play.google.com/store/apps/details?id=com.brainiumx.brain_game&hl=en_IN)

</div>
