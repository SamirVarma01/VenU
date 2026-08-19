import { BlurView } from 'expo-blur';
import type { PropsWithChildren } from 'react';
import { StyleSheet, View, type ViewStyle } from 'react-native';
import { radii } from '../../src/theme';

// Matches the design's `.glass-panel`: translucent black + blur + hairline
// white border. Split into a blur layer + a separate tint overlay rather
// than one BlurView with backgroundColor, since Android's blur tinting is
// less reliable than compositing them ourselves.
export function GlassCard({ children, style }: PropsWithChildren<{ style?: ViewStyle }>) {
  return (
    <View style={styles.wrapper}>
      <BlurView intensity={40} tint="dark" style={StyleSheet.absoluteFillObject} />
      <View style={[StyleSheet.absoluteFillObject, styles.tint]} />
      {/* `style` lands here, not on the wrapper — callers need to control
          layout (flexDirection, padding, alignItems) of the actual content,
          while the wrapper's own appearance (radius/border/overflow) stays fixed. */}
      <View style={[styles.content, style]}>{children}</View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    borderRadius: radii.xl,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    overflow: 'hidden',
  },
  tint: {
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
  },
  content: {
    flex: 1,
  },
});
