---
name: Flutter Commands
description: Essential commands and guidelines for developing Flutter apps using Gemini
---

# Flutter Commands
When working in this workspace, follow these specific instructions:

1. **Package Management**: Use the MCP tool `dart_pub` or terminal command `flutter pub add <package>` to add dependencies.
2. **Code Quality**: Ensure the code is properly formatted before finishing a task. Use `dart_format` or `dart format .`.
3. **Running the App**: To test, use the `launch_app` tool from the Dart MCP server or standard `flutter run` in the terminal for specific devices.
4. **Code Generation**: If using packages like `freezed` or `json_serializable`, remember to run:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. **Testing**: Add unit tests in the `test/` directory and run them via `flutter test` or `run_tests` MCP tool to ensure stability.
