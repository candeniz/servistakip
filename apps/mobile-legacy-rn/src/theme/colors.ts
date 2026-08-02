/** Renk token'ları. Marka rengi tenant.primary_color ile ezilebilir. */
export const colors = {
  // Marka
  primary: '#1E5EFF',
  primaryDark: '#1746C0',
  primaryLight: '#E8F0FF',

  // Nötr / yüzey
  background: '#F4F6FB',
  surface: '#FFFFFF',
  surfaceAlt: '#F0F2F7',
  border: '#E2E6EF',

  // Metin
  text: '#0F1B2D',
  textSecondary: '#5A6B85',
  textMuted: '#93A0B5',
  textInverse: '#FFFFFF',

  // Durumlar
  success: '#1DAA6D',
  successBg: '#E4F7EE',
  warning: '#F2A007',
  warningBg: '#FEF3DD',
  danger: '#E5484D',
  dangerBg: '#FCE9EA',
  info: '#0B7FD4',
  infoBg: '#E1F1FC',

  // Servis durum renkleri
  statusScheduled: '#93A0B5',
  statusPreparing: '#0B7FD4',
  statusActive: '#1DAA6D',
  statusDelayed: '#F2A007',
  statusPaused: '#7A5AF8',
  statusCompleted: '#5A6B85',
  statusCancelled: '#E5484D',

  // Harita / overlay
  overlay: 'rgba(15, 27, 45, 0.45)',
  mapRoute: '#1E5EFF',
} as const;

export type ColorToken = keyof typeof colors;
