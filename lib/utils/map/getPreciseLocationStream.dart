import 'package:geolocator/geolocator.dart';

Stream<Position> getPreciseLocationStream() {
  AndroidSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
    forceLocationManager: true,
  );

  return Geolocator.getPositionStream(locationSettings: locationSettings);
}
