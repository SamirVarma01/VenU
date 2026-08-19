import { useLocalSearchParams } from 'expo-router';
import { PlaceholderScreen } from '../../../components/PlaceholderScreen';

export default function ConcertDetailScreen() {
  const { concertId } = useLocalSearchParams<{ concertId: string }>();

  return (
    <PlaceholderScreen
      title="Concert details"
      description={`Concert ${concertId} — attendee list, "I'm going" RSVP, and the review feed for this show are coming soon.`}
    />
  );
}
