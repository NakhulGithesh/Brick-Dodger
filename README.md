# Brick Dodger

A fast-paced Flutter game built with the Flame engine where you dodge falling bricks and collect power-ups to achieve the high score!

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Flame Engine](https://img.shields.io/badge/Flame-1.x-orange?logo=flutter)

## 🎮 Features

- **Dynamic Gameplay**: Dodge falling bricks that increase in speed and frequency over time
- **Combo System**: Achieve 10 dodges in a row to increase your score multiplier
- **Near Miss Bonus**: Extra points for dodging bricks just in time!
- **Multiple Game Modes**: Choose your playstyle with different game modes
- **Power-ups**:
  - 🛡️ **Shield**: Protects you from one brick collision
  - 🐌 **Slow-Mo**: Temporarily slows down time
  - 📉 **Shrink**: Makes the player smaller and harder to hit
- **Visual "Juice"**: Screen shake, particle trails, and leaning movement for a premium feel
- **Persistent High Scores**: Your best score is saved locally
- **Retro Aesthetic**: Custom 'Press Start 2P' font and scrolling ground texture

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point
├── game/
│   ├── brick_dodger_game.dart   # Main game engine
│   ├── components/
│   │   ├── player.dart          # Player character
│   │   ├── brick.dart           # Falling brick obstacles
│   │   ├── safe_brick.dart      # Safe brick variants
│   │   ├── lava.dart            # Lava hazard component
│   │   ├── power_up.dart        # Collectible power-ups
│   │   ├── stamina_bar.dart     # Stamina UI component
│   │   ├── floating_text.dart   # Floating text effects
│   │   └── ground.dart          # Scrolling background
│   └── managers/
│       └── storage_helper.dart  # Local data persistence
└── overlays/
    ├── main_menu_overlay.dart   # Main menu UI
    └── mode_briefing_overlay.dart  # Game mode selection
```

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or higher)
- An IDE (VS Code, Android Studio) with Flutter and Dart plugins

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/NakhulGithesh/Brick-Dodger.git
   cd Brick-Dodger
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the game:
   ```bash
   flutter run
   ```

## 🎯 Controls

- **Left/Right Arrow** or **A/D Keys**: Move the player
- **Touch/Drag**: Mobile touch controls

## 🏗️ Development

The game is built using the **Flame Engine** for Flutter. Key files:

| File | Description |
|------|-------------|
| `brick_dodger_game.dart` | Core game loop and state management |
| `player.dart` | Player movement, collision, and stamina logic |
| `brick.dart` | Brick spawning, falling, and particle effects |
| `storage_helper.dart` | High score persistence with SharedPreferences |

### Dependencies

- `flame` - Game engine
- `flame_audio` - Audio management
- `google_fonts` - Typography
- `shared_preferences` - Local storage

## 📸 Screenshots

_Add screenshots of gameplay here_

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- Built with [Flame Engine](https://flame-engine.org/)
- Font: [Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P)

---

**Made with ❤️ using Flutter & Flame**
