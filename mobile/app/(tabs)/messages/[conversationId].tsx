import { useLocalSearchParams } from 'expo-router';
import { PlaceholderScreen } from '../../../components/PlaceholderScreen';

export default function ConversationScreen() {
  const { conversationId } = useLocalSearchParams<{ conversationId: string }>();

  return <PlaceholderScreen title="Conversation" description={`Chat thread ${conversationId} — coming soon.`} />;
}
