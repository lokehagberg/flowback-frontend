<!-- ChatContainer.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { websocketService, messagesStore, typingUsersStore, connectionStatusStore, chatParticipantsStore } from '$lib/api/websocketService';
  import MessageList from './MessageList.svelte';
  import MessageInput from './MessageInput.svelte';
  import TypingIndicator from './TypingIndicator.svelte';
  import ConnectionStatus from './ConnectionStatus.svelte';
  import { chat } from '$lib/api/chat';
  import type { Message, MessageChannelParticipant } from '$lib/api/chat';
  import type { ConnectionStatus as ConnectionStatusType } from '$lib/api/websocketService';

  export let channelId: number;
  export let userId: number;

  let typingTimeout: ReturnType<typeof setTimeout>;
  let messages: Message[] = [];
  let typingUsers: Set<number>;
  let connectionStatus: ConnectionStatusType;
  let participants: Map<number, { id: number; username: string; isTyping: boolean }>;
  let channelTitle = '';
  let channelType: 'direct' | 'group' = 'direct';
  let currentUsername = '';

  const unsubscribeMessages = messagesStore.subscribe((value) => {
    messages = value;
  });

  const unsubscribeTyping = typingUsersStore.subscribe((value) => {
    typingUsers = value;
  });

  const unsubscribeConnection = connectionStatusStore.subscribe((value) => {
    connectionStatus = value;
  });

  const unsubscribeParticipants = chatParticipantsStore.subscribe((value) => {
    participants = value;
  });

  async function loadChannelInfo() {
    try {
      // Get channel preview to determine type and title
      const preview = await chat.getChannelPreviews({ channel_id: channelId });
      if (preview.results.length > 0) {
        const channel = preview.results[0];
        channelTitle = channel.channel_title || '';
        channelType = channel.channel_origin_name === 'group' ? 'group' : 'direct';
      }

      // Get channel participants
      const participantsResponse = await chat.getParticipants(channelId);
      if (participantsResponse.results) {
        chatParticipantsStore.update(current => {
          const updated = new Map(current);
          participantsResponse.results.forEach((participant: MessageChannelParticipant) => {
            if (!updated.has(participant.user.id)) {
              updated.set(participant.user.id, {
                id: participant.user.id,
                username: participant.user.username,
                isTyping: false
              });
              if (participant.user.id === userId) {
                currentUsername = participant.user.username;
              }
            }
          });
          return updated;
        });
      }

      // Get channel messages
      const messagesResponse = await chat.getMessages(channelId, {
        limit: 50,
        order_by: 'created_at_desc'
      });
      if (messagesResponse.results) {
        messagesStore.set(messagesResponse.results.reverse());
      }
    } catch (error) {
      console.error('Error loading channel info:', error);
    }
  }

  onMount(async () => {
    await loadChannelInfo();
    websocketService.joinChannel(channelId);
  });

  onDestroy(() => {
    if (typingTimeout) clearTimeout(typingTimeout);
    websocketService.leaveChannel(channelId);
    unsubscribeMessages();
    unsubscribeTyping();
    unsubscribeConnection();
    unsubscribeParticipants();
  });

  function handleMessageSubmit(event: CustomEvent<string>) {
    const message = event.detail;
    try {
      websocketService.sendMessage(channelId, message);
    } catch (error) {
      console.error('Failed to send message:', error);
    }
  }

  function handleTyping() {
    if (typingTimeout) clearTimeout(typingTimeout);
    websocketService.sendTypingIndicator(channelId);
    
    typingTimeout = setTimeout(() => {
      // Typing timeout
    }, 3000);
  }

  $: participantsList = channelType === 'group' ? 
    Array.from(participants?.values() || [])
      .map(p => p.username)
      .join(', ') :
    Array.from(participants?.values() || [])
      .filter(p => p.id !== userId)
      .map(p => p.username)
      .join(', ');

  $: chatTitle = channelType === 'group' ? 
    channelTitle || 'Group Chat' : 
    participantsList ? `Chat with ${participantsList}` : 'Direct Message';
</script>

<div class="chat-container">
  <div class="chat-header">
    <ConnectionStatus status={connectionStatus} />
    <div class="chat-info">
      <div class="chat-title">{chatTitle}</div>
      {#if channelType === 'group' && participantsList}
        <div class="participants">
          Participants: {participantsList}
        </div>
      {/if}
    </div>
  </div>
  
  <div class="messages-wrapper">
    <MessageList {messages} {userId} />
    <TypingIndicator users={typingUsers} {userId} />
  </div>

  <MessageInput 
    on:message={handleMessageSubmit}
    on:typing={handleTyping}
    disabled={connectionStatus !== 'connected'} 
  />
</div>

<style>
  .chat-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    background-color: #f8f9fa;
    border-radius: 8px;
    overflow: hidden;
  }

  .chat-header {
    padding: 0.5rem;
    border-bottom: 1px solid #dee2e6;
    background-color: white;
  }

  .chat-info {
    padding: 0.5rem;
  }

  .chat-title {
    font-weight: 600;
    color: #111827;
    margin-bottom: 0.25rem;
  }

  .participants {
    font-size: 0.875rem;
    color: #6c757d;
  }

  .messages-wrapper {
    flex-grow: 1;
    overflow-y: auto;
    padding: 1rem;
    display: flex;
    flex-direction: column;
  }
</style> 