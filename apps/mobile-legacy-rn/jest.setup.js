/* eslint-disable no-undef */
// Native modüllerin test ortamında güvenli mock'ları.

jest.mock('expo-secure-store', () => ({
  getItemAsync: jest.fn(async () => null),
  setItemAsync: jest.fn(async () => undefined),
  deleteItemAsync: jest.fn(async () => undefined),
}));

jest.mock('expo-location', () => ({
  requestForegroundPermissionsAsync: jest.fn(async () => ({ status: 'granted' })),
  requestBackgroundPermissionsAsync: jest.fn(async () => ({ status: 'granted' })),
  getCurrentPositionAsync: jest.fn(async () => ({
    coords: { latitude: 41.0, longitude: 28.9, speed: 0, heading: 0, accuracy: 10 },
  })),
  watchPositionAsync: jest.fn(async () => ({ remove: jest.fn() })),
  Accuracy: { Balanced: 3, High: 4 },
}));

jest.mock('expo-notifications', () => ({
  getPermissionsAsync: jest.fn(async () => ({ status: 'granted' })),
  requestPermissionsAsync: jest.fn(async () => ({ status: 'granted' })),
  getExpoPushTokenAsync: jest.fn(async () => ({ data: 'ExponentPushToken[test]' })),
  setNotificationHandler: jest.fn(),
}));

jest.mock('expo-task-manager', () => ({
  defineTask: jest.fn(),
  isTaskRegisteredAsync: jest.fn(async () => false),
}));

jest.mock('react-native-maps', () => {
  const React = require('react');
  const MockMap = (props) => React.createElement('MockMap', props, props.children);
  const MockMarker = (props) => React.createElement('MockMarker', props, props.children);
  return {
    __esModule: true,
    default: MockMap,
    Marker: MockMarker,
    Polyline: (props) => React.createElement('MockPolyline', props),
    PROVIDER_GOOGLE: 'google',
  };
});
