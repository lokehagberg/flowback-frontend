<!-- ChatContainer.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { websocketService, messagesStore, typingUsersStore, connectionStatusStore } from '$lib/api/websocketService';
  import MessageList from './MessageList.svelte';
  import MessageInput from './MessageInput.svelte';
  import TypingIndicator from './TypingIndicator.svelte';
  import ConnectionStatus from './ConnectionStatus.svelte';
  import { chat } from '$lib/api/chat';
  import type { Message } from '$lib/api/chat';
  import type { ConnectionStatus as ConnectionStatusType } from '$lib/api/websocketService';
  import Button from '$lib/Generic/Button.svelte';

  export let channelId: number;
  export let userId: number;

  let typingTimeout: ReturnType<typeof setTimeout>;
  let messages: Message[] = [];
  let typingUsers = new Set<number>();
  let connectionStatus: ConnectionStatusType;
  let channelTitle = '';
  type ChannelType = 'direct' | 'group';
  let channelType: ChannelType = 'direct';
  let participantsList = '';
  let isParticipant = false;

  const unsubscribeMessages = messagesStore.subscribe((value) => {
    messages = value;
  });

  const unsubscribeTyping = typingUsersStore.subscribe((value) => {
    typingUsers = value;
  });

  const unsubscribeConnection = connectionStatusStore.subscribe((value) => {
    connectionStatus = value;
  });

  async function loadChannelInfo() {
    if (!channelId) return;
    
    try {
      // Get current user ID
      const userId = Number(localStorage.getItem('userId'));
      if (!userId) return;

      // Get channel participants
      const participantsResponse = await chat.getParticipants(channelId);
      const participants = participantsResponse.results || [];
      
      // Check if current user is a participant
      isParticipant = participants.some(p => p.user.id === userId && p.active);
      
      // Load message history regardless of WebSocket connection
      try {
        const messageHistory = await chat.getMessages(channelId, { 
          limit: 50, 
          order_by: 'created_at_asc'
        });
        if (messageHistory.results) {
          messagesStore.set(messageHistory.results);
        }
      } catch (error) {
        console.error('Error loading message history:', error);
      }
      
      // Determine chat type and title
      const preview = await chat.getChannelPreviews({ channel_id: channelId });
      if (preview.results.length > 0) {
        const channel = preview.results[0];
        channelTitle = channel.channel_title || '';
        channelType = channel.participants <= 2 ? 'direct' : 'group';
        
        if (channelType === 'direct') {
          // For DMs, show the other user's name
          const otherParticipant = participants.find(p => p.user.id !== userId);
          participantsList = otherParticipant ? otherParticipant.user.username : 'Unknown User';
        } else {
          // For groups, show all participants
          participantsList = participants
            .filter(p => p.active)
            .map(p => p.user.username)
            .join(', ');
        }
      }
    } catch (error) {
      console.error('Error loading channel info:', error);
    }
  }

  async function handleJoinChat() {
    try {
      if (!websocketService.isConnected()) {
        console.error('Cannot join chat - WebSocket not connected');
        return;
      }

      websocketService.joinChannel(channelId);
      isParticipant = true;
      await loadChannelInfo();
    } catch (error) {
      console.error('Failed to join chat:', error);
    }
  }

  async function handleLeaveChat() {
    try {
      if (!websocketService.isConnected()) {
        console.error('Cannot leave chat - WebSocket not connected');
        return;
      }

      // First send the disconnect message
      websocketService.leaveChannel(channelId);
      console.log('Sent disconnect_channel message for channel:', channelId);

      // Update local state
      isParticipant = false;
      messages = [];
      messagesStore.set([]);

      // Reload channel info to update UI
      await loadChannelInfo();
    } catch (error) {
      console.error('Failed to leave chat:', error);
    }
  }

  onMount(async () => {
    const token = localStorage.getItem('token');
    if (!token) {
      console.error('No token found');
      return;
    }

    // First ensure WebSocket is connected
    websocketService.connect(token);

    await loadChannelInfo();

    // If user is already a participant, join the channel
    if (isParticipant) {
      console.log('User is participant, joining channel:', channelId);
      websocketService.joinChannel(channelId);
    }
  });

  onDestroy(() => {
    if (typingTimeout) clearTimeout(typingTimeout);
    unsubscribeMessages();
    unsubscribeTyping();
    unsubscribeConnection();
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
    if (!isParticipant || connectionStatus !== 'connected') return;
    
    if (typingTimeout) clearTimeout(typingTimeout);
    
    // Send typing indicator
    websocketService.sendTypingIndicator(channelId);
    
    // Clear typing status after delay
    typingTimeout = setTimeout(() => {
      typingUsersStore.update(users => {
        const newUsers = new Set(users);
        newUsers.delete(userId);
        return newUsers;
      });
    }, 3000);
  }

  $: chatTitle = channelType === 'group' ? 
    (channelTitle || 'Group Chat') : 
    (participantsList ? `Chat with ${participantsList}` : 'Loading...');
</script>

<div class="chat-container">
  <div class="chat-header">
    <ConnectionStatus status={connectionStatus} />
    <div class="chat-info">
      <div class="chat-title-row">
        <div class="chat-title">{chatTitle}</div>
        <div class="chat-actions">
          {#if channelType === 'group'}
            {#if !isParticipant}
              <Button onClick={handleJoinChat} Class="join-btn">Join Chat</Button>
            {/if}
          {/if}
        </div>
      </div>
      {#if channelType === 'group' && participantsList}
        <div class="participants">
          Participants: {participantsList}
        </div>
      {/if}
    </div>
  </div>
  
  <div class="messages-wrapper">
    {#if isParticipant}
      <div class="messages-container">
        <MessageList {messages} {userId} />
        <div class="typing-indicator-container">
          <TypingIndicator {userId} />
        </div>
      </div>
    {:else}
      <div class="not-participant-message">
        {#if channelType === 'group'}
          Join this chat to see messages and participate in the conversation.
        {:else}
          You cannot participate in this conversation.
        {/if}
      </div>
    {/if}
  </div>

  <MessageInput 
    on:message={handleMessageSubmit}
    on:typing={handleTyping}
    disabled={!isParticipant || connectionStatus !== 'connected'} 
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

  .chat-title-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.25rem;
  }

  .chat-title {
    font-weight: 600;
    color: #111827;
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

  .messages-container {
    flex-grow: 1;
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .typing-indicator-container {
    margin-top: -0.5rem;
    margin-bottom: 0.25rem;
  }

  .not-participant-message {
    text-align: center;
    color: #6c757d;
    margin: auto;
    padding: 2rem;
  }

  .chat-actions {
    display: flex;
    gap: 0.5rem;
  }

  :global(.join-btn) {
    background-color: #4f46e5;
    color: white;
    padding: 0.5rem 1rem;
    border-radius: 0.375rem;
  }
</style> 