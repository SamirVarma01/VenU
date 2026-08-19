import { StyleSheet, Text, View } from 'react-native';
import { colors, radii, typography } from '../../src/theme';

type Tone = 'primary' | 'secondary' | 'tertiary' | 'neutral';

const TONE_COLORS: Record<Tone, { text: string; background: string; border: string }> = {
  primary: { text: colors.primary, background: 'rgba(221, 183, 255, 0.1)', border: 'rgba(221, 183, 255, 0.3)' },
  secondary: { text: colors.secondary, background: 'rgba(148, 222, 45, 0.1)', border: 'rgba(148, 222, 45, 0.3)' },
  tertiary: { text: colors.tertiary, background: 'rgba(76, 215, 246, 0.1)', border: 'rgba(76, 215, 246, 0.3)' },
  neutral: { text: colors.onSurfaceVariant, background: colors.surfaceVariant, border: colors.outlineVariant },
};

export function Chip({ label, tone = 'neutral' }: { label: string; tone?: Tone }) {
  const toneColors = TONE_COLORS[tone];
  return (
    <View style={[styles.chip, { backgroundColor: toneColors.background, borderColor: toneColors.border }]}>
      <Text style={[typography.labelSm, { color: toneColors.text }]}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  chip: {
    borderRadius: radii.full,
    borderWidth: 1,
    paddingHorizontal: 8,
    paddingVertical: 4,
    alignSelf: 'flex-start',
  },
});
