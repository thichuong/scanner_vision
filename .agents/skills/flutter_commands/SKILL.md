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
   - Sử dụng `PdfService` (tại `lib/services/pdf_service.dart`) để tạo PDF chuẩn A4.
   - Luôn sử dụng thuật toán Fit-to-page và **Auto-rotate** trong `PdfService` để đảm bảo ảnh không bị tràn lề và đúng hướng.
   - **Tự động hóa**: Sử dụng `PdfService.saveAndCopyPdf` để thực hiện đồng thời việc lưu file vào `Pictures/Scanner Vision` và copy đường dẫn vào Clipboard (nếu cài đặt cho phép).
   - Gọi `PdfService.openFile` để mở trình xem mặc định của hệ thống.
6. **Quyền truy cập (Permissions) & Lưu trữ**:
   - Đảm bảo `AndroidManifest.xml` và `Info.plist` đã khai báo quyền Camera, Gallery (Photos), và Storage.
   - Sử dụng `GalleryService.saveImagesToGallery` để lưu ảnh scan vào máy một cách chuyên nghiệp.
   - **Quản lý phiên quét (Sessions)**:
   - Sử dụng `StorageService` để lưu trữ dữ liệu lâu dài.
   - Quản lý dữ liệu tập trung qua `SessionProvider`. **Lưu ý**: `HomePage` quản lý trạng thái chọn nhiều và lọc trực tiếp.
   - Luôn thông báo cho người dùng khi phiên quét được lưu tự động.
7. **Testing**: 
   - Thêm unit tests trong thư mục `test/`.
   - Chạy test qua `flutter test` hoặc công cụ `run_tests` MCP.
