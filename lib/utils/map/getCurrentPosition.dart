import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentPosition() async {
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
