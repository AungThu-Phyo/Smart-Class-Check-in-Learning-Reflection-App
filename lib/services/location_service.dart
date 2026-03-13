import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Requests location permission and returns the current [Position].
  /// Throws a [LocationException] if permission is denied or services are off.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
          'Location services are disabled. Please enable them in settings.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
            'Location permission was denied. Please allow location access.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
          'Location permission is permanently denied. '
          'Please enable it in the app settings.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Returns a formatted string like "1.3521° N, 103.8198° E".
  static String formatPosition(double lat, double lon) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lonDir = lon >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, '
        '${lon.abs().toStringAsFixed(4)}° $lonDir';
  }
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}
