import 'package:geolocator/geolocator.dart';

Stream<Position> getPreciseLocationStream() {
  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best, // High precision
    distanceFilter: 0, // Distance in meters before update (optional)
  );

  return Geolocator.getPositionStream(locationSettings: locationSettings);
}
