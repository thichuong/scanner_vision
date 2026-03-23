class CCCDScanResult {
  final List<String> images;
  final String? qrData;
  final bool hasFace;
  final bool isComplete;

  CCCDScanResult({
    required this.images,
    this.qrData,
    this.hasFace = false,
    this.isComplete = false,
  });
}
