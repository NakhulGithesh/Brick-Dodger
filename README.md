# Brick Dodger

A fast-paced Flutter game built with the Flame engine where you dodge falling bricks and collect power-ups to achieve the high score!

## Features

- **Dynamic Gameplay**: Dodge falling bricks that increase in speed and frequency over time.
- **Combo System**: Achieve 10 dodges in a row to increase your score multiplier.
- **Near Miss Bonus**: Extra points for dodging bricks just in time!
- **Power-ups**:
  - **Shield**: Protects you from one brick collision.
  - **Slow-Mo**: Temporarily slows down time.
  - **Shrink**: Makes the player smaller and harder to hit.
- **Visual "Juice"**: Screen shake, particle trails, and leaning movement for a premium feel.
- **Persistent High Scores**: Your best score is saved locally.
- **Retro Aesthetic**: Custom 'Press Start 2P' font and scrolling ground texture.

## Project Structure

- `lib/main.dart`: Entry point of the application.
- `lib/game/`: Contains all game logic.
  - `brick_dodger_game.dart`: The main game engine class.
  - `components/`: Individual game entities.
    - `player.dart`: Player character with movement and collision logic.
    - `brick.dart`: Falling brick obstacles with particle trails.
    - `power_up.dart`: Collectible items that grant temporary buffs.
    - `ground.dart`: Scrolling background texture.
    - `cloud.dart`: Decorative background elements.
    - `floating_text.dart`: UI feedback for scores and combos.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
- An IDE (VS Code, Android Studio, etc.) with Flutter and Dart plugins.

### How to Run

1.  **Clone or Download** the project.
2.  Open the project in your terminal.
3.  Run `flutter pub get` to install dependencies (Flame, Google Fonts, SharedPreferences).
4.  Launch an emulator or connect a physical device.
5.  Run the application with:
    ```bash
    flutter run
    ```

## Development

The game is built using the **Flame Engine** for Flutter. Most game-related state and logic can be found in `lib/game/brick_dodger_game.dart`.

