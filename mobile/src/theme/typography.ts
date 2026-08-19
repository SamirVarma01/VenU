import type { TextStyle } from 'react-native';

// Font family keys match what app/_layout.tsx registers via useFonts() —
// RN references custom fonts by that registered key, not a CSS weight.
export const fonts = {
  displayXl: 'Anybody_800ExtraBold',
  headline: 'Anybody_700Bold',
  body: 'HankenGrotesk_400Regular',
  label: 'JetBrainsMono_500Medium',
} as const;

// Ported from the design's Tailwind fontSize scale. RN letterSpacing is in
// absolute px, so em values are converted against each preset's font size.
export const typography = {
  displayXl: {
    fontFamily: fonts.displayXl,
    fontSize: 48,
    lineHeight: 52,
    letterSpacing: -0.96, // -0.02em
  } satisfies TextStyle,
  headlineLgMobile: {
    fontFamily: fonts.headline,
    fontSize: 28,
    lineHeight: 34,
  } satisfies TextStyle,
  headlineLg: {
    fontFamily: fonts.headline,
    fontSize: 32,
    lineHeight: 40,
    letterSpacing: -0.32, // -0.01em
  } satisfies TextStyle,
  bodyMd: {
    fontFamily: fonts.body,
    fontSize: 16,
    lineHeight: 24,
  } satisfies TextStyle,
  labelSm: {
    fontFamily: fonts.label,
    fontSize: 12,
    lineHeight: 16,
    letterSpacing: 0.6, // 0.05em
  } satisfies TextStyle,
} as const;
