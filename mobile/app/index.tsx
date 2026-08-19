import { Redirect } from 'expo-router';
import { useAuth } from '../src/features/auth/AuthContext';

// Entry route: sends the user to the right stack based on auth state.
// (auth)/_layout and (tabs)/_layout each also guard themselves, so this is
// just about picking where to land first.
export default function Index() {
  const { user, isEmailVerified, isInitializing } = useAuth();

  if (isInitializing) return null;
  if (user && isEmailVerified) return <Redirect href="/(tabs)/concerts" />;
  return <Redirect href="/(auth)/sign-in" />;
}
