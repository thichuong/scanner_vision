# Scanner Vision 📸

Scanner Vision là một ứng dụng Flutter chuyên nghiệp dùng để quét tài liệu, tận dụng sức mạnh của Google ML Kit để mang lại trải nghiệm quét nhanh chóng, chính xác và hiệu quả ngay trên thiết bị di động.

## 🌟 Tính năng chính

- **Quét tài liệu thông minh**: Tự động phát hiện cạnh, căn chỉnh và cắt tài liệu bằng Google ML Kit Document Scanner API.
- **Tự động sao chép hình ảnh**: 
  - Ngay sau khi scan thành công, ảnh kết quả được tự động đưa vào Clipboard hệ thống dưới dạng Binary (sử dụng `pasteboard`).
  - Hỗ trợ dán trực tiếp vào các ứng dụng chat (Zalo, Messenger, v.v.).
- **Tự động lưu Gallery**: Tự động lưu ảnh đã quét vào thư viện ảnh của thiết bị (Photos/Gallery) ngay khi có kết quả.
- **Ghép và xuất tài liệu CCCD**:
  - Tích hợp quét mã QR để trích xuất thông tin tự động (Họ tên, ngày sinh, số định danh, ...).
  - Quy trình quét 2 mặt mượt mà, chuyển tiếp trực tiếp giữa các mặt quét.
  - Ghép 2 mặt CCCD vào một trang A4 duy nhất.
- **Tự động hóa PDF & In ấn**:
  - Hỗ trợ xuất file PDF khổ A4 chuẩn với thuật toán Fit-to-page, **Auto-rotate** và **Auto-scale**.
  - **Tự động lưu**: File PDF được lưu vào thư mục `Pictures/Scanner Vision`.
  - **Copy Path & Mở file**: Tự động sao chép đường dẫn file và mở trình xem mặc định (có thể cấu hình).
  - **In ấn linh hoạt**: Hỗ trợ xem trước in với các tùy chọn zoom, hướng trang, và số ảnh trên mỗi trang (N-up).
- **Quản lý lịch sử chuyên nghiệp**: 
  - Lưu và quản lý các phiên quét (Sessions) trong bộ nhớ lâu dài.
  - **Tự động lưu vào lịch sử** ngay sau khi scan xong.
  - **Chọn nhiều & Lọc**: Hỗ trợ chọn nhiều phiên để in hàng loạt và lọc theo loại (Tài liệu, CCCD).
  - Xem chi tiết, in lại hoặc chia sẻ bất cứ lúc nào.
- **Cài đặt cá nhân hóa**: 
  - Tùy chỉnh bật/tắt: Xem trước in, Tự động lưu Gallery, Tự động copy ảnh/đường dẫn PDF.
  - Hỗ trợ giao diện Sáng/Tối (Light/Dark Mode).

## 🛠 Công nghệ sử dụng

- **Flutter**: Framework phát triển ứng dụng mobile.
- **Google ML Kit**: 
  - `document_scanner`: Xử lý quét tài liệu.
  - `barcode_scanning`: Đọc mã QR trên CCCD.
- **pdf & printing**: Tạo và xử lý file PDF, hỗ trợ in ấn.
- **pasteboard**: Xử lý sao chép hình ảnh Binary vào Clipboard.
- **gal**: Lưu trữ hình ảnh vào Gallery hệ thống.
- **provider**: Quản lý trạng thái ứng dụng tập trung.
- **shared_preferences**: Lưu trữ thiết lập người dùng.

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

