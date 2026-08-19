import { MaterialIcons } from '@expo/vector-icons';
import { BlurView } from 'expo-blur';
import { useRouter } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Image,
  Linking,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Chip } from '../../../components/theme/Chip';
import { GlassCard } from '../../../components/theme/GlassCard';
import { GradientButton } from '../../../components/theme/GradientButton';
import { GradientText } from '../../../components/theme/GradientText';
import { fetchUpcomingConcerts } from '../../../src/features/concerts/api';
import { colors, spacing, typography } from '../../../src/theme';
import type { Concert } from '../../../src/types/models';

// Ported from legacy-ios/ViewsConcertBrowserView.swift + RepositoriesConcertRepository.swift,
// restyled to match designs/concert-discovery.html.
// Still missing: filtering by "near your college" (see src/features/concerts/api.ts).
export default function ConcertsScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [concerts, setConcerts] = useState<Concert[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchUpcomingConcerts()
      .then(setConcerts)
      .catch((e) => setError(e instanceof Error ? e.message : 'Failed to load concerts'))
      .finally(() => setIsLoading(false));
  }, []);

  // The design's "Featured Artists" carousel has no equivalent flag in our
  // data — as a placeholder heuristic, feature whichever upcoming concerts
  // have an image, until there's a real curation mechanism.
  const featured = useMemo(() => concerts.filter((c) => c.imageURL).slice(0, 3), [concerts]);

  function openConcert(concertId: string) {
    router.push({ pathname: '/(tabs)/concerts/[concertId]', params: { concertId } });
  }

  return (
    <View style={styles.container}>
      <BlurView intensity={60} tint="dark" style={[styles.topBar, { paddingTop: insets.top + spacing.xs }]}>
        <MaterialIcons name="search" size={24} color={colors.primary} />
        <GradientText style={styles.wordmark}>VenU</GradientText>
        <MaterialIcons name="notifications" size={24} color={colors.primary} />
      </BlurView>

      <ScrollView contentContainerStyle={[styles.scrollContent, { paddingTop: insets.top + 90 }]}>
        {isLoading && <ActivityIndicator style={styles.spinner} color={colors.primary} />}
        {!!error && <Text style={styles.error}>{error}</Text>}

        {featured.length > 0 && (
          <View style={styles.section}>
            <Text style={[typography.headlineLgMobile, styles.sectionTitle]}>Featured Artists</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.featuredRow}>
              {featured.map((concert) => (
                <Pressable key={concert.id} onPress={() => openConcert(concert.id)} style={styles.featuredCard}>
                  <Image source={{ uri: concert.imageURL }} style={styles.featuredImage} />
                  <View style={styles.featuredOverlay} />
                  <Text style={[typography.headlineLgMobile, styles.featuredName]} numberOfLines={2}>
                    {concert.artistName}
                  </Text>
                </Pressable>
              ))}
            </ScrollView>
          </View>
        )}

        <View style={styles.section}>
          <View style={styles.sectionHeaderRow}>
            <Text style={[typography.headlineLgMobile, styles.sectionTitle]}>Near You</Text>
            <MaterialIcons name="location-on" size={20} color={colors.secondary} />
          </View>

          <View style={styles.feedList}>
            {concerts.map((concert) => (
              <ConcertCard key={concert.id} concert={concert} onPress={() => openConcert(concert.id)} />
            ))}
            {!isLoading && concerts.length === 0 && (
              <Text style={styles.empty}>
                No concerts yet — run `npm run sync-concerts` in scripts/ to pull real shows from Ticketmaster.
              </Text>
            )}
          </View>
        </View>
      </ScrollView>
    </View>
  );
}

function ConcertCard({ concert, onPress }: { concert: Concert; onPress: () => void }) {
  const date = new Date(concert.date);
  const month = date.toLocaleDateString(undefined, { month: 'short' }).toUpperCase();
  const day = date.getDate();

  return (
    <GlassCard style={styles.feedCard}>
      <Pressable onPress={onPress}>
        <View style={styles.feedImageWrap}>
          {concert.imageURL ? (
            <Image source={{ uri: concert.imageURL }} style={styles.feedImage} />
          ) : (
            <View style={[styles.feedImage, styles.feedImagePlaceholder]} />
          )}
          <View style={styles.dateBadge}>
            <Text style={[typography.labelSm, styles.dateBadgeMonth]}>{month}</Text>
            <Text style={[typography.headlineLgMobile, styles.dateBadgeDay]}>{day}</Text>
          </View>
        </View>

        <View style={styles.feedBody}>
          {!!concert.genre && (
            <View style={styles.chipRow}>
              <Chip label={concert.genre} tone="secondary" />
            </View>
          )}
          <Text style={[typography.headlineLgMobile, styles.feedTitle]} numberOfLines={1}>
            {concert.artistName}
          </Text>
          <View style={styles.venueRow}>
            <MaterialIcons name="location-on" size={16} color={colors.onSurfaceVariant} />
            <Text style={[typography.bodyMd, styles.venueName]} numberOfLines={1}>
              {concert.venueName}
            </Text>
          </View>

          <View style={styles.feedFooter}>
            <GradientButton
              label="Get Tix"
              onPress={() => concert.ticketURL && Linking.openURL(concert.ticketURL)}
            />
          </View>
        </View>
      </Pressable>
    </GlassCard>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  topBar: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 10,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.marginMobile,
    paddingBottom: spacing.xs,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.1)',
  },
  wordmark: {
    ...typography.displayXl,
  },
  scrollContent: {
    paddingBottom: 120,
    paddingHorizontal: spacing.marginMobile,
    gap: spacing.lg,
  },
  spinner: { marginTop: 20 },
  error: { color: colors.error, ...typography.bodyMd },
  section: {
    gap: spacing.sm,
  },
  sectionHeaderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
  },
  sectionTitle: {
    color: colors.onSurface,
  },
  featuredRow: {
    gap: spacing.sm,
  },
  featuredCard: {
    width: 240,
    height: 280,
    borderRadius: 12,
    overflow: 'hidden',
  },
  featuredImage: {
    ...StyleSheet.absoluteFillObject,
  },
  featuredOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(10, 10, 10, 0.35)',
  },
  featuredName: {
    position: 'absolute',
    bottom: spacing.sm,
    left: spacing.sm,
    right: spacing.sm,
    color: '#fff',
  },
  feedList: {
    gap: spacing.sm,
  },
  feedCard: {},
  feedImageWrap: {
    height: 180,
  },
  feedImage: {
    width: '100%',
    height: '100%',
  },
  feedImagePlaceholder: {
    backgroundColor: colors.surfaceContainer,
  },
  dateBadge: {
    position: 'absolute',
    top: spacing.xs,
    right: spacing.xs,
    backgroundColor: 'rgba(53, 53, 52, 0.8)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 8,
    paddingHorizontal: spacing.xs,
    paddingVertical: 4,
    alignItems: 'center',
  },
  dateBadgeMonth: {
    color: colors.primary,
  },
  dateBadgeDay: {
    color: colors.onSurface,
    fontSize: 20,
    lineHeight: 22,
  },
  feedBody: {
    padding: spacing.md,
    gap: spacing.base,
  },
  chipRow: {
    flexDirection: 'row',
    marginBottom: spacing.base,
  },
  feedTitle: {
    color: colors.onSurface,
  },
  venueRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.base,
  },
  venueName: {
    color: colors.onSurfaceVariant,
    flexShrink: 1,
  },
  feedFooter: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    marginTop: spacing.sm,
    paddingTop: spacing.sm,
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.05)',
  },
  empty: {
    ...typography.bodyMd,
    color: colors.onSurfaceVariant,
    textAlign: 'center',
    marginTop: 40,
  },
});
