import 'package:geolocator/geolocator.dart';

Future<bool> getLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future<bool>.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future<bool>.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future<bool>.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  return true;
}
