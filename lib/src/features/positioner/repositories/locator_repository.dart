import 'package:pure_extensions/pure_extensions.dart';

abstract class LocatorRepository {
  LocatorRepository._();

  /// Open the position service page to enable it
  Stream<bool> openServicePage();

  /// Receive the service status of the location
  Stream<bool> get onServiceChanges;

  /// Request the current position of the user
  Stream<GeoPoint> get currentPosition;

  /// Track the current position of the user
  Stream<GeoPoint> get onPositionChanges;
}
