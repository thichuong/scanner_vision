# Scanner Vision 📸

Scanner Vision là một ứng dụng Flutter chuyên nghiệp dùng để quét tài liệu, tận dụng sức mạnh của Google ML Kit để mang lại trải nghiệm quét nhanh chóng, chính xác và hiệu quả ngay trên thiết bị di động.

## 🌟 Tính năng chính

- **Quét tài liệu thông minh**: Tự động phát hiện cạnh, căn chỉnh và cắt tài liệu bằng Google ML Kit Document Scanner API.
- **Quét CCCD (ID Card)**: 
  - Tích hợp quét mã QR để trích xuất thông tin tự động (Họ tên, ngày sinh, số định danh, ...).
  - Ghép 2 mặt CCCD vào một trang A4 duy nhất để thuận tiện cho việc in ấn/photo.
- **Xuất PDF chuyên nghiệp**:
  - Hỗ trợ xuất file PDF khổ A4 chuẩn.
  - Tự động thay đổi hướng trang (Xoay trang) dựa trên kích thước ảnh gốc.
  - Thuật toán Scale thông minh đảm bảo nội dung luôn hiển thị trọn vẹn trong trang giấy (Fit-to-page).
- **Quản lý lịch sử**: Lưu trữ và quản lý các phiên quét (Sessions) một cách khoa học.
- **Cài đặt linh hoạt**: Tùy chỉnh nơi lưu trữ, xem trước bản in và giao diện (Sáng/Tối).

## 🛠 Công nghệ sử dụng

- **Flutter**: Framework phát triển ứng dụng mobile.
- **Google ML Kit**: 
  - `document_scanner`: Xử lý quét tài liệu.
  - `barcode_scanning`: Đọc mã QR trên CCCD.
- **pdf & printing**: Tạo và xử lý file PDF, hỗ trợ in ấn trực tiếp.
- **shared_preferences**: Lưu trữ cấu hình người dùng.

## 🚀 Bắt đầu

### Yêu cầu hệ thống
- Flutter SDK (phiên bản ổn định mới nhất).
- Thiết bị Android/iOS thực để trải nghiệm tính năng quét (ML Kit yêu cầu phần cứng thật).

### Cài đặt
1. Clone repository:
   ```bash
   git clone https://github.com/thichuong/scanner_vision.git
   ```
2. Cài đặt dependencies:
   ```bash
   flutter pub get
   ```
3. Chạy ứng dụng:
   ```bash
   flutter run
   ```

## 📐 Kiến trúc

Chi tiết về kiến trúc hệ thống xem tại [architecture.md](./architecture.md).

---
*Phát triển bởi [Thích Ưởng](https://github.com/thichuong)*

