import { MaterialIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { GlassCard } from '../../components/theme/GlassCard';
import { TextField } from '../../components/theme/TextField';
import { fetchAllSchools } from '../../src/features/schools/api';
import { colors, spacing, typography } from '../../src/theme';
import type { School } from '../../src/types/models';

export default function SchoolSelectScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [schools, setSchools] = useState<School[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchText, setSearchText] = useState('');

  useEffect(() => {
    fetchAllSchools()
      .then(setSchools)
      .catch((e) => setError(e instanceof Error ? e.message : 'Failed to load schools'))
      .finally(() => setIsLoading(false));
  }, []);

  const filteredSchools = useMemo(() => {
    if (!searchText) return schools;
    const needle = searchText.toLowerCase();
    return schools.filter(
      (s) =>
        s.name.toLowerCase().includes(needle) ||
        s.city.toLowerCase().includes(needle) ||
        s.state.toLowerCase().includes(needle)
    );
  }, [schools, searchText]);

  function selectSchool(school: School) {
    router.push({
      pathname: '/(auth)/sign-up',
      params: { schoolId: school.id, schoolName: school.name, emailDomain: school.emailDomain },
    });
  }

  return (
    <View style={[styles.container, { paddingTop: insets.top + spacing.lg }]}>
      <Text style={typography.headlineLg}>Find your school</Text>
      <Text style={styles.subtitle}>VenU is only for verified college students.</Text>

      <TextField
        placeholder="Search by school, city, or state"
        value={searchText}
        onChangeText={setSearchText}
        autoCapitalize="none"
        style={styles.searchInput}
      />

      {isLoading && <ActivityIndicator style={styles.spinner} color={colors.primary} />}
      {!!error && <Text style={styles.error}>{error}</Text>}

      <FlatList
        data={filteredSchools}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        renderItem={({ item }) => (
          <Pressable onPress={() => selectSchool(item)}>
            <GlassCard style={styles.row}>
              <View style={styles.rowContent}>
                <Text style={[typography.headlineLgMobile, styles.rowTitle]}>{item.name}</Text>
                <Text style={styles.rowSubtitle}>
                  {item.city}, {item.state} · @{item.emailDomain}
                </Text>
              </View>
              <MaterialIcons name="chevron-right" size={24} color={colors.onSurfaceVariant} />
            </GlassCard>
          </Pressable>
        )}
        ListEmptyComponent={!isLoading ? <Text style={styles.empty}>No schools found yet.</Text> : null}
      />

      <Pressable onPress={() => router.push('/(auth)/sign-in')}>
        <Text style={styles.link}>Already have an account? Sign in</Text>
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
  searchInput: {
    marginTop: spacing.xs,
  },
  spinner: { marginTop: spacing.md },
  error: { color: colors.error, ...typography.bodyMd },
  list: { gap: spacing.sm, paddingBottom: spacing.lg },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: spacing.sm,
  },
  rowContent: { flex: 1, gap: 2 },
  rowTitle: { color: colors.onSurface, fontSize: 18, lineHeight: 22 },
  rowSubtitle: { ...typography.labelSm, color: colors.onSurfaceVariant },
  empty: {
    ...typography.bodyMd,
    color: colors.onSurfaceVariant,
    textAlign: 'center',
    marginTop: spacing.xl,
  },
  link: {
    ...typography.bodyMd,
    color: colors.tertiary,
    textAlign: 'center',
    marginBottom: spacing.md,
  },
});
