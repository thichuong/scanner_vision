---
trigger: always_on
glob: "**/*.dart, pubspec.yaml"
description: Flutter and Dart rules for this document scanner project
---

# Flutter Agent Rules

## 1. Project Context & Purpose
- This is a Flutter document scanner application leveraging Google ML Kit for document edge detection, cropping, and scanning.
- Output files are typically PDFs or JPEGs.
- Assume mobile-first development (Android/iOS) with performance on physical devices as a top priority.

## 2. Architecture & Code Structure
- **State Management**: Use robust state management (e.g., Provider, Riverpod, or BLoC) consistently. Do not mix patterns unless necessary.
- **Widget Modularity**: Keep the `build` methods clean. Extract complex responsive UI into smaller, reusable UI components inside `lib/widgets/`.
- **Business Logic**: Isolate business logic (ML Kit processing, file saving) from UI. Use repository or service classes (e.g., `lib/services/`).

## 3. Tooling and Dependencies
- **MCP server**: Whenever possible, use Dart toolset provided by the `dart-mcp-server` (e.g., `dart_pub`, `dart_format`, `dart_analyze`, `launch_app`).
- **Build Runner**: For generated code (e.g., `freezed`, `json_serializable`), run `dart run build_runner build -d`.
- Do not write standard shell script `pub get` if the MCP action exists, unless you explicitly need shell output.

## 4. UI/UX Quality
- Always aim for premium, smooth UI with micro-animations. Transitions between scanning, cropping, and viewing must feel native and fluid.
- Support both Dark Mode and Light Mode natively.

## 5. Agent Communication
- Prefer concise, actionable explanations.
- Speak in Vietnamese by default in conversations, or bilingual (Vietnamese chat + English code comments).
- Commit messages must be clear, indicating what changed and why.
