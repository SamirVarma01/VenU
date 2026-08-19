import { PlaceholderScreen } from '../../../components/PlaceholderScreen';

// src/features/friends/api.ts has stub CRUD over the `friendships`
// collection; this screen doesn't call it yet.
export default function FriendsScreen() {
  return (
    <PlaceholderScreen
      title="Friends"
      description="Friend requests and your friends list will live here. Not built yet — see src/features/friends/api.ts."
    />
  );
}
