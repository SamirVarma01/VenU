import { MaterialIcons } from '@expo/vector-icons';
import { BlurView } from 'expo-blur';
import { Redirect, Tabs } from 'expo-router';
import { StyleSheet } from 'react-native';
import { useAuth } from '../../src/features/auth/AuthContext';
import { colors } from '../../src/theme';

export default function TabLayout() {
  const { user, isEmailVerified, isInitializing } = useAuth();

  if (isInitializing) return null;

  if (!user) {
    return <Redirect href="/(auth)/sign-in" />;
  }
  if (!isEmailVerified) {
    return <Redirect href="/(auth)/verify-email" />;
  }

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.secondary,
        tabBarInactiveTintColor: colors.onSurfaceVariant,
        tabBarStyle: styles.tabBar,
        tabBarBackground: () => <BlurView intensity={60} tint="dark" style={StyleSheet.absoluteFillObject} />,
      }}>
      <Tabs.Screen
        name="concerts"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, size }) => <MaterialIcons name="explore" color={color} size={size} />,
        }}
      />
      {/* Buddy-matching moved into the concert detail screen ("Find a
          Concert Buddy" / "Potential Buddies"), matching the design — this
          route stays reachable, just not as its own tab. */}
      <Tabs.Screen name="friends" options={{ href: null }} />
      <Tabs.Screen
        name="messages"
        options={{
          title: 'Messages',
          tabBarIcon: ({ color, size }) => <MaterialIcons name="chat-bubble" color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="feed"
        options={{
          title: 'Vibe Check',
          tabBarIcon: ({ color, size }) => <MaterialIcons name="groups" color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, size }) => <MaterialIcons name="person" color={color} size={size} />,
        }}
      />
    </Tabs>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    position: 'absolute',
    backgroundColor: 'transparent',
    borderTopColor: 'rgba(255, 255, 255, 0.1)',
    borderTopWidth: 1,
  },
});
