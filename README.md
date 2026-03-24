# Scanner Vision 📸

Scanner Vision là một ứng dụng Flutter chuyên nghiệp dùng để quét tài liệu, tận dụng sức mạnh của Google ML Kit để mang lại trải nghiệm quét nhanh chóng, chính xác và hiệu quả ngay trên thiết bị di động.

## 🌟 Tính năng chính

- **Quét tài liệu thông minh**: Tự động phát hiện cạnh, căn chỉnh và cắt tài liệu bằng Google ML Kit Document Scanner API.
- **Tự động sao chép hình ảnh**: 
  - Ngay sau khi scan thành công, ảnh kết quả được tự động đưa vào Clipboard hệ thống.
  - Hỗ trợ dán trực tiếp vào các ứng dụng chat (Zalo, Messenger, v.v.) hoặc trình chỉnh sửa ảnh.
- **Ghép và xuất tài liệu CCCD**:
  - Tích hợp quét mã QR để trích xuất thông tin tự động (Họ tên, ngày sinh, số định danh, ...).
  - Quy trình quét 2 mặt mượt mà, chuyển tiếp trực tiếp giữa các mặt quét.
  - Ghép 2 mặt CCCD vào một trang A4 duy nhất (Hỗ trợ cả hướng Dọc và Ngang).
- **Tự động hóa PDF & In ấn**:
  - Hỗ trợ xuất file PDF khổ A4 chuẩn với thuật toán Fit-to-page thông minh.
  - **Tự động lưu**: File PDF được lưu vào thư mục `Pictures/Scanner Vision` trên thiết bị.
  - **Copy Path**: Tự động copy đường dẫn file đã lưu vào Clipboard.
  - **Mở file tức thì**: Tự động mở file PDF bằng ứng dụng mặc định ngay sau khi tạo.
- **Quản lý lịch sử chuyên nghiệp**: 
  - Lưu và quản lý các phiên quét (Sessions) trong thư mục tài liệu ứng dụng.
  - Xem chi tiết hình ảnh, copy thông tin dữ liệu (đối với CCCD) và thực hiện in lại bất cứ lúc nào.
- **Cài đặt cá nhân hóa**: Tùy chỉnh bật/tắt xem trước bản in, vị trí lưu trữ và chế độ Dark Mode.

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

