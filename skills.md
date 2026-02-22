# Skills and Context: Brick Dodger Game
This file contains the core operational instructions and best practices for developing the "Brick Dodger" Flutter game. As an AI agent, I have absorbed these rules and will apply them to all future commands and code generation in this project.

## 1. Tech Stack Alignment
- **Framework:** Flutter 3.x
- **Game Engine:** Flame Engine
- **Core Components:** Game loop components must extend or utilize Flame-specific constructs such as `PositionComponent`, `FlameGame`, and `HasCollisionDetection` instead of standard Flutter `Widget`s for game entities.

## 2. Performance Constraints
- **Movement Logic:** All movement, physics, and over-time logic must utilize the `dt` (delta time) parameter passed in the `update()` loop.
- **Target:** Maintain a smooth 60 FPS animation target, optimized for mobile native platforms (especially Android).

## 3. Automation Rules
- **Dependencies:** I am authorized to automatically run `flutter pub get` whenever dependencies are modified or added.
- **Formatting:** I am authorized to automatically run `dart format .` after modifying or creating Dart files to maintain code structure.

## 4. Memory Safety
- **Garbage Collection:** Off-screen entities (like falling bricks that have passed below the screen bounds) must explicitly call `removeFromParent()` to be cleaned up by Flame, preventing memory leaks over time.

## 5. Error Handling
- **Build Failures:** In the event of a build failure or compilation error, I will first run and analyze the output of `flutter analyze` to understand the root cause before attempting any secondary fixes.

## 6. Project Architecture & File Structure
Maintain a modular and decoupled project structure follows:
- `/lib/components/` - Standalone visual or interactable game components (Player, Brick, etc.)
- `/lib/game/` - The main game loop logic, FlameGame sub-classes, and managers (SpawnManager, etc.)
- `/lib/overlays/` - Standard Flutter widgets used as UI overlays on top of the Flame canvas (Menus, Game Over screens, HUDs)

## 7. Context: Assumed Mechanics
- **Random Spawning:** Bricks will spawn dynamically along the horizontal axis, scaled by mathematical bounds, with frequency that can increase over time to scale difficulty.
- **Movement Mechanics:** Player horizontal movement is controlled via touch/pan gestures bounded by the screen edges, while obstacles move downwards strictly along the vertical axis (using delta time).
