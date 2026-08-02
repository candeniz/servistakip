import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/geo.dart' as geo;
import '../data/models/stop.dart';

/// Canlı harita: aracı, durakları ve güzergâh çizgisini gösterir.
///
/// NOT: Harita karolarının görünmesi için Google Maps API anahtarı gerekir
/// (README > Harita API anahtarı). Anahtar yoksa harita boş görünür ancak
/// uygulama çökmeden çalışır.
class LiveMap extends StatelessWidget {
  const LiveMap({
    super.key,
    this.vehicleLocation,
    this.vehicleHeading = 0,
    this.stops = const [],
    this.routePath = const [],
    this.highlightStopId,
    this.height = 260,
  });

  final geo.LatLngPoint? vehicleLocation;
  final double vehicleHeading;
  final List<Stop> stops;
  final List<geo.LatLngPoint> routePath;
  final String? highlightStopId;
  final double height;

  @override
  Widget build(BuildContext context) {
    final center = vehicleLocation ??
        (stops.isNotEmpty ? stops.first.point : const geo.LatLngPoint(41.0, 28.9));

    final markers = <Marker>{
      for (final stop in stops)
        Marker(
          markerId: MarkerId(stop.id),
          position: LatLng(stop.latitude, stop.longitude),
          infoWindow: InfoWindow(title: stop.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            stop.id == highlightStopId ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRose,
          ),
        ),
      if (vehicleLocation != null)
        Marker(
          markerId: const MarkerId('vehicle'),
          position: LatLng(vehicleLocation!.latitude, vehicleLocation!.longitude),
          rotation: vehicleHeading,
          flat: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
    };

    final polylines = <Polyline>{
      if (routePath.length > 1)
        Polyline(
          polylineId: const PolylineId('route'),
          points: routePath.map((p) => LatLng(p.latitude, p.longitude)).toList(),
          color: AppColors.primary,
          width: 4,
        ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(center.latitude, center.longitude),
            zoom: 12.5,
          ),
          markers: markers,
          polylines: polylines,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          liteModeEnabled: false,
        ),
      ),
    );
  }
}
