---
name: Operational Integrity System
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#44474d'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#75777e'
  outline-variant: '#c5c6ce'
  surface-tint: '#4e5f7c'
  primary: '#04162f'
  on-primary: '#ffffff'
  primary-container: '#1a2b45'
  on-primary-container: '#8293b2'
  inverse-primary: '#b6c7e8'
  secondary: '#0051d5'
  on-secondary: '#ffffff'
  secondary-container: '#316bf3'
  on-secondary-container: '#fefcff'
  tertiary: '#201400'
  on-tertiary: '#ffffff'
  tertiary-container: '#3a2702'
  on-tertiary-container: '#aa8d5e'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d6e3ff'
  primary-fixed-dim: '#b6c7e8'
  on-primary-fixed: '#091c35'
  on-primary-fixed-variant: '#374763'
  secondary-fixed: '#dbe1ff'
  secondary-fixed-dim: '#b4c5ff'
  on-secondary-fixed: '#00174b'
  on-secondary-fixed-variant: '#003ea8'
  tertiary-fixed: '#ffdeab'
  tertiary-fixed-dim: '#e3c28e'
  on-tertiary-fixed: '#271900'
  on-tertiary-fixed-variant: '#59431b'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 20px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style

This design system is engineered for B2B SaaS environments where operational clarity and reliability are paramount. The brand personality is **authoritative, systematic, and precise**, designed to instill confidence in logistics managers and field technicians alike. 

The aesthetic follows a **Modern Corporate** approach, leaning into high-functional minimalism. It prioritizes data density without sacrificing legibility. Every visual element serves a functional purpose, eschewing decorative flourishes for a "realistic operational feel." The interface uses card-based layouts to compartmentalize complex logistics data, ensuring that real-time status updates are the focal point of the user experience.

## Colors

The color palette is anchored by **Deep Navy (#1A2B45)**, providing a stable, institutional foundation for navigation and structural elements. **Trusting Blue (#2563EB)** is reserved exclusively for primary actions, links, and active states, creating a clear "path of value" for the user.

The semantic palette is critical for real-time status tracking:
- **Success (Green):** Indicates completed tasks, active vehicles, or "On Time" status.
- **Warning (Orange):** Highlights delays, approaching deadlines, or pending approvals.
- **Error/Critical (Red):** Flags cancellations, hardware failures, or urgent alerts.

The system supports a native **Dark Mode**, where the Deep Navy surfaces transition to a deep charcoal, maintaining contrast ratios for low-light field operations while reducing eye strain.

## Typography

The typography system utilizes **Hanken Grotesk** for its exceptional legibility and modern, engineering-led character. It provides the "Sharp" corporate look required for B2B dashboards. For technical data points such as plate numbers, tracking IDs, and timestamps, **JetBrains Mono** is used to ensure character distinction and a high-tech operational feel.

Turkish language support is prioritized, ensuring specific characters (ğ, ü, ş, i, ö, ç) maintain consistent vertical alignment and kerning. 
- Use **Title Case** for headings and **Sentence case** for body copy.
- Labels for status indicators (e.g., "YOLDA", "TAMAMLANDI") should always use the `label-md` mono-type for a "tag" or "badge" appearance.

## Layout & Spacing

The design system employs a **Fluid-Fixed Hybrid Grid**. The sidebar and navigation elements are fixed-width to maintain a consistent "Control Center" frame, while the main content area (Map views, Data tables, Card grids) is fluid.

- **Grid:** A 12-column grid for desktop with 20px gutters. 
- **Touch Targets:** All interactive elements must maintain a minimum height/width of 44px (11 units of the base 4px spacer) to accommodate field use.
- **Data Tables:** Use condensed vertical padding (8px) to maximize information density while maintaining horizontal margins (16px) for scanability.
- **Map Focus:** When a map view is active, the layout shifts to an "Overlay" model where control panels float on the right or bottom of the screen to maximize geographic context.

## Elevation & Depth

Depth is communicated through **Tonal Layers** and sharp, defined shadows. We avoid heavy blurs to maintain a "structured" feel.

1.  **Level 0 (Background):** Solid neutral gray (#F8FAFC) for the canvas.
2.  **Level 1 (Cards/Sidebar):** White surface with a 1px border (#E2E8F0) and no shadow. Used for secondary information.
3.  **Level 2 (Active Elements):** White surface with a 1px border and a "Structured Shadow" (Y: 4px, Blur: 6px, Opacity: 0.05, Color: Navy). Used for primary dashboard cards.
4.  **Level 3 (Modals/Overlays):** White surface with a "Command Shadow" (Y: 12px, Blur: 24px, Opacity: 0.1, Color: Navy). Used for urgent alerts or detail views.

Border-bottoms are used in lists and tables instead of shadows to maintain a flat, professional "ledger" appearance.

## Shapes

The shape language is **Soft (0.25rem / 4px base)**. This reflects a "modern-industrial" aesthetic—professional and orderly without being overly friendly or consumer-oriented. 

- **Primary Buttons & Inputs:** 4px radius (rounded-sm).
- **Dashboard Cards:** 8px radius (rounded-lg).
- **Status Badges:** 4px radius (never pill-shaped) to keep the look structured and serious.
- **Selection States:** A 2px stroke is used in addition to background color shifts to indicate focus, ensuring accessibility for users with color vision deficiencies.

## Components

### Buttons
- **Primary:** Deep Navy background with White text. Bold, 14px uppercase text for high visibility.
- **Action:** Trusting Blue background. Used for "Yeni Kayıt", "Takip Başlat".
- **Ghost:** Transparent background with 1px Navy border. Used for "İptal" or secondary actions.

### Cards & Status Indicators
- **Operational Cards:** Must include a left-hand color-coded accent bar (4px width) reflecting the current status (Green, Orange, Red).
- **Badges:** Small, rectangular tags using JetBrains Mono text. Example: `[PLAKA: 34 ABC 123]`.

### Input Fields
- Labels must always be visible above the input (never placeholder-only).
- Active state: 2px Trusting Blue border.
- Error state: 1px Red border with a "Critical" icon suffix.

### Lists & Tables
- **Zebra Striping:** Use for long data sets to assist horizontal scanning.
- **Interaction:** Row-hover should trigger a slight background tint change (#F1F5F9).

### Map Controls
- Floating, square icon buttons (40x40px) with high-contrast icons for "Zoom", "My Location", and "Layer Toggle". These should have the Level 3 elevation.

### Additional Components
- **Timeline/Stepper:** A vertical line component to track the service process (e.g., "Depoda", "Yolda", "Teslim Edildi").
- **Real-time Pulse:** A small animated dot next to "Canlı Takip" indicators to signify active data streaming.