import { PlaceholderScreen } from '../../../components/PlaceholderScreen';

// src/features/messaging/api.ts has stub CRUD over the `messages`
// collection; this screen doesn't call it yet.
export default function MessagesScreen() {
  return (
    <PlaceholderScreen
      title="Messages"
      description="Your conversations will show up here. Not built yet — see src/features/messaging/api.ts."
    />
  );
}
