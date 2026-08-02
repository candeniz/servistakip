// Expo + npm workspaces (monorepo) Metro yapılandırması.
// packages/shared kaynak kodunu Metro'nun izlemesi ve çözebilmesi için gereklidir.
const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const projectRoot = __dirname;
const monorepoRoot = path.resolve(projectRoot, '../..');

const config = getDefaultConfig(projectRoot);

// 1) Monorepo kökünü izle (packages/shared değişiklikleri yakalansın)
config.watchFolders = [monorepoRoot];

// 2) node_modules çözümlemesi: önce app, sonra kök
config.resolver.nodeModulesPaths = [
  path.resolve(projectRoot, 'node_modules'),
  path.resolve(monorepoRoot, 'node_modules'),
];

// 3) Tekilleştirme: iki React kopyası olmasın
config.resolver.disableHierarchicalLookup = true;

module.exports = config;
