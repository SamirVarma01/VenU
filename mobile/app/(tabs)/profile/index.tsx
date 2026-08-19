import { Pressable, StyleSheet } from 'react-native';
import { ThemedText } from '../../../components/ThemedText';
import { ThemedView } from '../../../components/ThemedView';
import { useAuth } from '../../../src/features/auth/AuthContext';
import { signOut } from '../../../src/features/auth/api';

export default function ProfileScreen() {
  const { user } = useAuth();

  return (
    <ThemedView style={styles.container}>
      <ThemedText type="title">Profile</ThemedText>
      <ThemedText style={styles.email}>{user?.email}</ThemedText>
      <ThemedText style={styles.note}>
        Full profile editing (display name, bio, public/private toggle) is written in legacy-ios/ but hasn't been
        ported yet.
      </ThemedText>

      <Pressable style={styles.button} onPress={() => signOut()}>
        <ThemedText style={styles.buttonText}>Sign out</ThemedText>
      </Pressable>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, paddingTop: 60, gap: 12 },
  email: { opacity: 0.7 },
  note: { opacity: 0.6, marginVertical: 8 },
  button: {
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: '#8888',
    borderRadius: 10,
    padding: 14,
    alignItems: 'center',
    marginTop: 8,
  },
  buttonText: { fontWeight: '600' },
});
