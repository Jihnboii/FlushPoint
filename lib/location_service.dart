import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    await Permission.location.request();
  }
}

Future<Position> getCurrentLocation() async {
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}