class CCCDModel {
  final String id;
  final String oldId;
  final String fullName;
  final String dob;
  final String gender;
  final String address;
  final String issueDate;
  final List<String> capturedImages;

  CCCDModel({
    required this.id,
    required this.oldId,
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.address,
    required this.issueDate,
    required this.capturedImages,
  });

  factory CCCDModel.fromQR(String qrString, {List<String> images = const []}) {
    // Format: Số CCCD|Số CMND cũ|Họ và tên|Ngày sinh|Giới tính|Địa chỉ thường trú|Ngày cấp
    final parts = qrString.split('|');
    if (parts.length >= 7) {
      return CCCDModel(
        id: parts[0],
        oldId: parts[1],
        fullName: parts[2],
        dob: parts[3],
        gender: parts[4],
        address: parts[5],
        issueDate: parts[6],
        capturedImages: images,
      );
    }
    // Fallback error parsing
    return CCCDModel(
      id: parts.isNotEmpty ? parts[0] : '',
      oldId: '',
      fullName: 'Unknown',
      dob: '',
      gender: '',
      address: qrString,
      issueDate: '',
      capturedImages: images,
    );
  }
}
