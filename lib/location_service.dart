import 'package:geolocator/geolocator.dart';

class LocationService {
  // Memeriksa dan meminta izin lokasi
  static Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Mengambil koordinat GPS
  static Future<Position?> getCurrentLocation() async {
    bool hasPermission = await checkPermission();

    if (!hasPermission) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
