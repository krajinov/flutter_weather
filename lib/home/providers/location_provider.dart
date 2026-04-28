import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationProvider = FutureProvider<Position>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentPosition();
});

class SelectedLocationNotifier extends Notifier<LatLng?> {
  @override
  LatLng? build() => null;

  void updateLocation(LatLng location) {
    state = location;
  }
}

final selectedLocationProvider =
    NotifierProvider<SelectedLocationNotifier, LatLng?>(() {
      return SelectedLocationNotifier();
    });
