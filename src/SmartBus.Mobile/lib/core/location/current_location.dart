import 'package:geolocator/geolocator.dart';

/// Lightweight wrapper around `geolocator` that returns the current position
/// or `null` if location services / permissions aren't available.
/// Callers should treat a null result as "skip the location-based behaviour"
/// rather than fail the action — boarding still works without GPS.
class CurrentLocation {
  const CurrentLocation();

  Future<({double latitude, double longitude})?> tryFetch({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
      return (latitude: pos.latitude, longitude: pos.longitude);
    } catch (_) {
      // Any failure (timeout, plugin error, simulator without coords) is
      // treated as "no location" — boarding still proceeds.
      return null;
    }
  }
}
