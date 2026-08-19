import { Redirect, Stack } from 'expo-router';
import { useAuth } from '../../src/features/auth/AuthContext';

export default function AuthLayout() {
  const { user, isEmailVerified, isInitializing } = useAuth();

  if (isInitializing) return null;

  // Already signed in and verified — no reason to see onboarding again.
  if (user && isEmailVerified) {
    return <Redirect href="/(tabs)/concerts" />;
  }

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="school-select" />
      <Stack.Screen name="sign-up" />
      <Stack.Screen name="sign-in" />
      <Stack.Screen name="verify-email" />
    </Stack>
  );
}
