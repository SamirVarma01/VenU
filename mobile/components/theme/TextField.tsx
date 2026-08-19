import { StyleSheet, TextInput, type TextInputProps } from 'react-native';
import { colors, radii, spacing, typography } from '../../src/theme';

export function TextField(props: TextInputProps) {
  return (
    <TextInput
      placeholderTextColor={colors.onSurfaceVariant}
      selectionColor={colors.primary}
      {...props}
      style={[styles.input, props.style]}
    />
  );
}

const styles = StyleSheet.create({
  input: {
    ...typography.bodyMd,
    color: colors.onSurface,
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: radii.lg,
    paddingHorizontal: spacing.sm,
    paddingVertical: 12,
  },
});
