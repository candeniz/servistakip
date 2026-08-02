module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      // Yol takma adları (tsconfig paths ile uyumlu)
      [
        'module-resolver',
        {
          alias: {
            '@': './src',
            '@servis/shared': '../../packages/shared/src',
          },
          extensions: ['.ts', '.tsx', '.js', '.jsx', '.json'],
        },
      ],
      // Reanimated eklentisi her zaman son sırada olmalı
      'react-native-reanimated/plugin',
    ],
  };
};
