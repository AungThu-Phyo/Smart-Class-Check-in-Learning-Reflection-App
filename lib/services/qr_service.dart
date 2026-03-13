class QrService {
  String normalize(String value) {
    return value.trim().toUpperCase();
  }

  bool matches({
    required String scannedValue,
    required String expectedValue,
  }) {
    return normalize(scannedValue) == normalize(expectedValue);
  }
}
