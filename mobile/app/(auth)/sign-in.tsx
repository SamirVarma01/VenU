import { useRouter } from 'expo-router';
import { useState } from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { GradientButton } from '../../components/theme/GradientButton';
import { TextField } from '../../components/theme/TextField';
import { signIn, signOut } from '../../src/features/auth/api';
import { colors, spacing, typography } from '../../src/theme';

export default function SignInScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  async function handleSignIn() {
    if (!email || !password) {
      setError('Please enter your email and password.');
      return;
    }

    setIsLoading(true);
    setError('');

    try {
      const firebaseUser = await signIn(email, password);

      if (!firebaseUser.emailVerified) {
        await signOut();
        router.replace('/(auth)/verify-email');
        return;
      }
      // (tabs)/_layout redirects to concerts automatically once
      // AuthContext picks up the signed-in, verified user.
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Something went wrong.');
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <View style={[styles.container, { paddingTop: insets.top + spacing.xl }]}>
      <Text style={typography.headlineLg}>Welcome back</Text>

      <View style={styles.form}>
        <TextField
          placeholder="Email"
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
        />
        <TextField placeholder="Password" value={password} onChangeText={setPassword} secureTextEntry />
      </View>

      {!!error && <Text style={styles.error}>{error}</Text>}

      {isLoading ? (
        <ActivityIndicator color={colors.primary} style={styles.spinner} />
      ) : (
        <GradientButton
          label="Sign in"
          onPress={handleSignIn}
          style={styles.button}
          textStyle={typography.headlineLgMobile}
        />
      )}

      <Pressable onPress={() => router.push('/(auth)/school-select')}>
        <Text style={styles.link}>New here? Create an account</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    paddingHorizontal: spacing.marginMobile,
    gap: spacing.md,
  },
  form: {
    gap: spacing.sm,
  },
  error: { color: colors.error, ...typography.bodyMd },
  spinner: { marginTop: spacing.sm },
  button: {
    paddingVertical: 14,
  },
  link: {
    ...typography.bodyMd,
    color: colors.tertiary,
    textAlign: 'center',
  },
});
