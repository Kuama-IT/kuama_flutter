import 'package:pure_extensions/pure_extensions.dart';

abstract class LocatorRepository {
  LocatorRepository._();

  /// Open the position service page to enable it
  Future<bool> openServicePage();

  /// Receive the service status of the location
  Stream<bool> get onServiceChanges;

  /// Check if the position service is enabled
  Future<bool> checkService();

  /// Request the current position of the user
  Future<GeoPoint> get currentPosition;

  /// Track the current position of the user
  Stream<GeoPoint> get onPositionChanges;
}
