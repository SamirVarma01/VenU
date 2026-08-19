import { PlaceholderScreen } from '../../../components/PlaceholderScreen';

// src/features/reviews/api.ts has stub CRUD over the new `reviews`
// collection; this screen doesn't call it yet.
export default function FeedScreen() {
  return (
    <PlaceholderScreen
      title="Feed"
      description="Concert reviews and posts from people at your school will show up here. Not built yet — see src/features/reviews/api.ts."
    />
  );
}
