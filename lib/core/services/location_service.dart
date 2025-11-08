// lib/services/location_service.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _latKey = 'user_latitude';
  static const String _lngKey = 'user_longitude';

  /// Ask for location permission on app launch.
  /// Returns true if granted + current position saved.
  static Future<bool> requestAndSaveLocation() async {
    // Check if already granted
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      await _saveCurrentPosition();
      return true;
    }

    // Request permission
    final result = await Permission.locationWhenInUse.request();
    if (result.isGranted) {
      await _saveCurrentPosition();
      return true;
    }

    // Denied – show a dialog? (handle in UI)
    return false;
  }

  /// Get user's current GPS position and save to prefs.
  static Future<void> _saveCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, position.latitude);
    await prefs.setDouble(_lngKey, position.longitude);
  }

  /// Get saved location (fallback to Manila if none).
  static Future<LocationData?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lng = prefs.getDouble(_lngKey);
    if (lat != null && lng != null) {
      return LocationData(lat, lng);
    }
    return null; // Or default to {14.5995, 120.9842} (Manila)
  }
}

class LocationData {
  final double latitude;
  final double longitude;

  const LocationData(this.latitude, this.longitude);
}
