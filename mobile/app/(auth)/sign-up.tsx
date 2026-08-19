import { useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { GradientButton } from '../../components/theme/GradientButton';
import { TextField } from '../../components/theme/TextField';
import { createUserProfile, extractDomain, signUp } from '../../src/features/auth/api';
import { colors, spacing, typography } from '../../src/theme';

export default function SignUpScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { schoolId, schoolName, emailDomain } = useLocalSearchParams<{
    schoolId: string;
    schoolName: string;
    emailDomain: string;
  }>();

  const [displayName, setDisplayName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const isFormValid =
    !!schoolId &&
    displayName.trim().length > 0 &&
    extractDomain(email) === emailDomain &&
    password.length >= 8 &&
    password === confirmPassword;

  async function handleSignUp() {
    if (!isFormValid) {
      setError('Please fill out all fields correctly. Your email must match your school domain.');
      return;
    }

    setIsLoading(true);
    setError('');

    try {
      const firebaseUser = await signUp(email, password);
      const now = Date.now();
      await createUserProfile({
        id: firebaseUser.uid,
        email,
        displayName,
        schoolID: schoolId,
        isEmailVerified: false,
        isProfilePublic: true,
        createdAt: now,
        updatedAt: now,
      });
      router.replace('/(auth)/verify-email');
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Something went wrong.');
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <View style={[styles.container, { paddingTop: insets.top + spacing.lg }]}>
      <Text style={typography.headlineLg}>Create your account</Text>
      <Text style={styles.subtitle}>{schoolName}</Text>

      <View style={styles.form}>
        <TextField placeholder="Full name" value={displayName} onChangeText={setDisplayName} />
        <TextField
          placeholder={`you@${emailDomain ?? 'school.edu'}`}
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
        />
        <TextField
          placeholder="Password (min 8 characters)"
          value={password}
          onChangeText={setPassword}
          secureTextEntry
        />
        <TextField
          placeholder="Confirm password"
          value={confirmPassword}
          onChangeText={setConfirmPassword}
          secureTextEntry
        />
      </View>

      {!!error && <Text style={styles.error}>{error}</Text>}

      {isLoading ? (
        <ActivityIndicator color={colors.primary} style={styles.spinner} />
      ) : (
        <GradientButton
          label="Sign up"
          onPress={handleSignUp}
          style={styles.button}
          textStyle={typography.headlineLgMobile}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    paddingHorizontal: spacing.marginMobile,
    gap: spacing.sm,
  },
  subtitle: {
    ...typography.bodyMd,
    color: colors.onSurfaceVariant,
    marginBottom: spacing.xs,
  },
  form: {
    gap: spacing.sm,
  },
  error: { color: colors.error, ...typography.bodyMd },
  spinner: { marginTop: spacing.sm },
  button: {
    paddingVertical: 14,
    marginTop: spacing.xs,
  },
});
