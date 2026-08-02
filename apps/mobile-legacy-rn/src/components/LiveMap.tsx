import { StyleSheet, View } from 'react-native';
import MapView, { Marker, Polyline, PROVIDER_GOOGLE } from 'react-native-maps';
import type { LatLng, Stop } from '@servis/shared';
import { borderRadius, colors } from '@/theme';
import { MapVehicleMarker } from './MapVehicleMarker';

export interface LiveMapProps {
  vehicleLocation?: LatLng | null;
  vehicleHeading?: number;
  vehiclePlate?: string;
  stops?: Stop[];
  routePath?: LatLng[];
  highlightStopId?: string;
  height?: number;
}

/**
 * Canlı harita (native). Aracı, durakları ve güzergâh çizgisini gösterir.
 * Web platformunda LiveMap.web.tsx fallback'i devreye girer.
 */
export function LiveMap({
  vehicleLocation,
  vehicleHeading = 0,
  vehiclePlate,
  stops = [],
  routePath = [],
  highlightStopId,
  height = 260,
}: LiveMapProps) {
  const initialRegion = {
    latitude: vehicleLocation?.latitude ?? stops[0]?.latitude ?? 41.0,
    longitude: vehicleLocation?.longitude ?? stops[0]?.longitude ?? 28.9,
    latitudeDelta: 0.08,
    longitudeDelta: 0.08,
  };

  return (
    <View style={[styles.container, { height }]}>
      <MapView
        style={StyleSheet.absoluteFill}
        provider={PROVIDER_GOOGLE}
        initialRegion={initialRegion}
        showsUserLocation={false}
        toolbarEnabled={false}
      >
        {routePath.length > 1 ? (
          <Polyline coordinates={routePath} strokeColor={colors.mapRoute} strokeWidth={4} />
        ) : null}

        {stops.map((stop) => (
          <Marker
            key={stop.id}
            coordinate={{ latitude: stop.latitude, longitude: stop.longitude }}
            title={stop.name}
            pinColor={stop.id === highlightStopId ? colors.primary : colors.textSecondary}
          />
        ))}

        {vehicleLocation ? (
          <MapVehicleMarker coordinate={vehicleLocation} heading={vehicleHeading} plate={vehiclePlate} />
        ) : null}
      </MapView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    borderRadius: borderRadius.lg,
    overflow: 'hidden',
    backgroundColor: colors.surfaceAlt,
  },
});
