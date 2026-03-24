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
- **State Management**: Sử dụng `Provider` làm giải pháp quản lý trạng thái chính (`lib/providers/`). Luôn sử dụng `context.watch<T>()` để lắng nghe thay đổi và `context.read<T>()` để gọi các phương thức trong Provider.
- **Folder Structure**: 
    - `lib/pages/`: Chứa các màn hình UI.
    - `lib/providers/`: Chứa các lớp `ChangeNotifier` quản lý trạng thái (`SettingsProvider`, `SessionProvider`).
    - `lib/services/`: Chứa các lớp logic độc lập (`PdfService`, `ScannerService`, `StorageService`, `SettingsService`, `ClipboardService`, `GalleryService`).
    - `lib/models/`: Chứa các data models.
- **Widget Modularity**: Giữ phương thức `build` ngắn gọn. Trích xuất UI phức tạp thành các widget nhỏ trong `lib/widgets/`.
- **Business Logic**: Tách biệt logic kinh doanh ra khỏi UI bằng cách sử dụng Services và Providers.
- **External APIs**: Use dedicated utility methods for Clipboard and File System operations to ensure consistency.

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

## 6. **Quyền truy cập (Permissions)**:
   - Đảm bảo `AndroidManifest.xml` và `Info.plist` đã khai báo quyền Camera, Gallery (Photos), và Storage.
   - Sử dụng thư mục `getApplicationDocumentsDirectory` để lưu trữ file lâu dài của ứng dụng.
   - Các file PDF xuất bản được lưu tập trung trong `Pictures/Scanner Vision`.
## 7. **Tự động hóa (Automation)**:
   - Sử dụng `PdfService.saveAndCopyPdf` để lưu file và copy đường dẫn vào Clipboard trong một bước (tuân thủ `SettingsProvider`).
   - Dùng `PdfService.openFile` để kích hoạt trình xem file hệ thống sau khi lưu thành công.
   - Sử dụng `ClipboardService.copyImagesToClipboard` (từ `pasteboard`) để tự động copy ảnh scan vào clipboard dưới dạng binary.
   - Sử dụng `GalleryService.saveImagesToGallery` (từ `gal`) để tự động lưu ảnh vào thư viện thiết bị.
   - **Lưu ý Android**: `AndroidManifest.xml` phải cấu hình `FileProvider` với authority `${applicationId}.provider` để `pasteboard` hoạt động chính xác.
## 8. **Testing**:
   - Thêm unit tests trong thư mục `test/`.
   - Chạy test qua `flutter test` hoặc công cụ `run_tests` MCP.
