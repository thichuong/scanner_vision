---
name: Flutter Commands
description: Essential commands and guidelines for developing Flutter apps using Gemini
---

# Flutter Commands
When working in this workspace, follow these specific instructions for the Scanner Vision project:

1. **Package Management**: Use the MCP tool `dart_pub` or terminal command `flutter pub add <package>` to add dependencies.
2. **Code Quality**: Ensure the code is properly formatted before finishing a task. Use `dart_format` or `dart format .`.
3. **Running the App**: 
   - Use `launch_app` or `flutter run`.
   - **Lưu ý quan trọng**: ML Kit Document Scanner yêu cầu thiết bị thực và Google Play Services (trên Android). Không thể chạy tính năng quét trên Emulator.
4. **Code Generation**: Khi thay đổi `CCCDModel` hoặc các model khác dùng `json_serializable`:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. **Xử lý PDF & In ấn**: 
   - Sử dụng `PdfService` để tạo PDF chuẩn A4 (Hỗ trợ `generateDocumentPdfBytes` và `generateCCCDPdfBytes`).
   - Luôn sử dụng thuật toán Fit-to-page trong `PdfService` để đảm bảo ảnh không bị tràn lề.
   - **Tự động hóa**: Sử dụng `PdfService.saveAndCopyPdf` để thực hiện đồng thời việc lưu file vào `Pictures/Scanner Vision` và copy đường dẫn vào Clipboard.
   - Gọi `PdfService.openFile` để mở trình xem mặc định của hệ thống.
6. **Quyền truy cập (Permissions)**:
   - Đảm bảo `AndroidManifest.xml` và `Info.plist` đã khai báo quyền Camera và Gallery (Photos/Storage).
   - Sử dụng thư mục `getApplicationDocumentsDirectory` để lưu trữ dữ liệu phiên quét (sessions) lâu dài.
7. **Testing**: 
   - Thêm unit tests trong thư mục `test/`.
   - Chạy test qua `flutter test` hoặc công cụ `run_tests` MCP.
