import MaskedView from '@react-native-masked-view/masked-view';
import { LinearGradient } from 'expo-linear-gradient';
import { Text, type StyleProp, type TextStyle } from 'react-native';
import { primaryGradient } from '../../src/theme';

// Used sparingly, matching the design: the "VenU" wordmark and a couple of
// headline moments. RN has no CSS-style text gradient, so this masks a
// LinearGradient with the text shape via MaskedView.
export function GradientText({ children, style }: { children: string; style?: StyleProp<TextStyle> }) {
  return (
    <MaskedView maskElement={<Text style={style}>{children}</Text>}>
      <LinearGradient colors={primaryGradient} start={{ x: 0, y: 0 }} end={{ x: 1, y: 0 }}>
        <Text style={[style, { opacity: 0 }]}>{children}</Text>
      </LinearGradient>
    </MaskedView>
  );
}
