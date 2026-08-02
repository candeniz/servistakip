import { StyleSheet, Text, View } from 'react-native';
import { Marker } from 'react-native-maps';
import type { LatLng } from '@servis/shared';
import { colors } from '@/theme';

interface MapVehicleMarkerProps {
  coordinate: LatLng;
  heading?: number;
  plate?: string;
}

/** Harita üzerindeki araç işareti (native). */
export function MapVehicleMarker({ coordinate, heading = 0, plate }: MapVehicleMarkerProps) {
  return (
    <Marker coordinate={coordinate} anchor={{ x: 0.5, y: 0.5 }} flat rotation={heading} title={plate}>
      <View style={styles.marker}>
        <Text style={styles.icon}>🚐</Text>
      </View>
    </Marker>
  );
}

const styles = StyleSheet.create({
  marker: {
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: colors.surface,
    borderWidth: 2,
    borderColor: colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  icon: { fontSize: 16 },
});
