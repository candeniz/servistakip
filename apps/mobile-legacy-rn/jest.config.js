module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg|react-native-maps|@servis/.*))',
  ],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@servis/shared$': '<rootDir>/../../packages/shared/src',
    '^@servis/shared/(.*)$': '<rootDir>/../../packages/shared/src/$1',
  },
  collectCoverageFrom: ['src/**/*.{ts,tsx}'],
};
