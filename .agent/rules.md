# Gemini Rules for Scanner Vision

## 1. Project Context
This is a Flutter document scanner app. Always consider performance, memory usage, and camera lifecycle management when writing code for this project.

## 2. Architecture & Design
- **State Management**: Consistently use the established state management solution (e.g., Provider, Riverpod, or BLoC).
- **Modularity**: Break down large widgets into smaller, reusable components in `lib/widgets/`.
- **UI/UX Aesthetics**: Create a premium and responsive user experience. Avoid basic material defaults without thought; use customized, modern themes.

## 3. Communication
- Communicate clearly in Vietnamese (as preferred by the user) or English when discussing technical concepts.
- Provide succinct explanations of why a certain approach was taken.
- Focus on the `lib/` folder for Dart code. Avoid touching native code (`android/`, `ios/`) unless explicitly requested or necessary for integrations like ML Kit.
