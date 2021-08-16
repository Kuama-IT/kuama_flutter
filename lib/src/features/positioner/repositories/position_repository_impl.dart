import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:kuama_flutter/kuama_flutter.dart';
import 'package:kuama_flutter/positioner.dart';
import 'package:pure_extensions/src/dart/primitives/geo_point.dart';

class PositionRepositoryImpl implements PositionRepository {
  final GeolocatorPlatform geoLocator = GetIt.I();

  @override
  Future<GeoPoint> get currentPosition async {
    final position = await geoLocator.getCurrentPosition();
    return position.toGeoPoint();
  }

  @override
  Stream<GeoPoint> get onPositionChanges async* {
    await for (final position in geoLocator.getPositionStream()) {
      yield position.toGeoPoint();
    }
  }

  @override
  Future<bool> checkService() async {
    return await geoLocator.isLocationServiceEnabled();
  }

  @override
  Stream<bool> get onServiceChanges async* {
    await for (final status in geoLocator.getServiceStatusStream()) {
      switch (status) {
        case ServiceStatus.disabled:
          yield false;
          break;
        case ServiceStatus.enabled:
          yield true;
          break;
      }
    }
  }

  @override
  Future<bool> openServicePage() async {
    return await geoLocator.openLocationSettings();
  }
}

extension _PositionToGeoPoint on Position {
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
}
