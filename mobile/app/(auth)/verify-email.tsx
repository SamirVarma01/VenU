import { doc, updateDoc } from 'firebase/firestore';
import { useRouter } from 'expo-router';
import { useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { GradientButton } from '../../components/theme/GradientButton';
import { useAuth } from '../../src/features/auth/AuthContext';
import { resendVerificationEmail } from '../../src/features/auth/api';
import { auth } from '../../src/firebase/config';
import { usersCollection } from '../../src/firebase/collections';
import { colors, spacing, typography } from '../../src/theme';

const RESEND_COOLDOWN_SECONDS = 60;

export default function VerifyEmailScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { refreshUser } = useAuth();
  const [isChecking, setIsChecking] = useState(false);
  const [message, setMessage] = useState('Check your inbox for a verification link.');
  const [cooldown, setCooldown] = useState(0);

  useEffect(() => {
    if (cooldown <= 0) return;
    const timer = setInterval(() => setCooldown((s) => Math.max(0, s - 1)), 1000);
    return () => clearInterval(timer);
  }, [cooldown]);

  async function handleResend() {
    try {
      await resendVerificationEmail();
      setMessage('Verification email sent! Check your inbox.');
      setCooldown(RESEND_COOLDOWN_SECONDS);
    } catch (e) {
      setMessage(e instanceof Error ? e.message : 'Failed to resend email.');
    }
  }

  async function handleCheckVerified() {
    setIsChecking(true);
    try {
      // Updates both Firebase's copy and the shared AuthContext state —
      // the (tabs) auth guard reads the latter, so without this it would
      // still see the pre-verification state and bounce back here.
      await refreshUser();
      if (auth.currentUser?.emailVerified) {
        await updateDoc(doc(usersCollection(), auth.currentUser.uid), {
          isEmailVerified: true,
          updatedAt: Date.now(),
        });
        router.replace('/(tabs)/concerts');
        return;
      }
      setMessage('Not verified yet — check your inbox and try again.');
    } catch (e) {
      setMessage(e instanceof Error ? e.message : 'Something went wrong.');
    } finally {
      setIsChecking(false);
    }
  }

  return (
    <View style={[styles.container, { paddingTop: insets.top + spacing.xl }]}>
      <Text style={typography.headlineLg}>Verify your email</Text>
      <Text style={styles.subtitle}>We sent a link to {auth.currentUser?.email ?? 'your college email'}.</Text>
      <Text style={styles.message}>{message}</Text>

      {isChecking ? (
        <ActivityIndicator color={colors.primary} style={styles.spinner} />
      ) : (
        <GradientButton
          label="I've verified my email"
          onPress={handleCheckVerified}
          style={styles.button}
          textStyle={typography.headlineLgMobile}
        />
      )}

      <Pressable style={styles.secondaryButton} onPress={handleResend} disabled={cooldown > 0}>
        <Text style={cooldown > 0 ? styles.linkDisabled : styles.link}>
          {cooldown > 0 ? `Resend email (${cooldown}s)` : 'Resend verification email'}
        </Text>
      </Pressable>
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
  },
  message: {
    ...typography.bodyMd,
    color: colors.onSurface,
    marginBottom: spacing.sm,
  },
  spinner: { marginTop: spacing.sm },
  button: {
    paddingVertical: 14,
  },
  secondaryButton: { alignItems: 'center', marginTop: spacing.md },
  link: { ...typography.bodyMd, color: colors.tertiary },
  linkDisabled: { ...typography.bodyMd, color: colors.onSurfaceVariant, opacity: 0.5 },
});
