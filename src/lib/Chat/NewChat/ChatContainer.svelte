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
  import Button from '$lib/Generic/Button.svelte';

  export let channelId: number;
  export let userId: number;

  let typingTimeout: ReturnType<typeof setTimeout>;
  let messages: Message[] = [];
  let typingUsers: Set<number>;
  let connectionStatus: ConnectionStatusType;
  let participants: Map<number, { id: number; username: string; isTyping: boolean }>;
  let channelTitle = '';
  type ChannelType = 'direct' | 'group';
  let channelType: ChannelType = 'direct';
  let currentUsername = '';
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

  const unsubscribeParticipants = chatParticipantsStore.subscribe((value) => {
    participants = value;
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
      console.log(preview);
      if (preview.results.length > 0) {
        const channel = preview.results[0];
        channelTitle = channel.channel_title || '';
        channelType = channel.participants <= 2 ? 'direct' : 'group';
        
        // Log detailed participant information
        console.log(`\n=== Chat Info for Channel ${channelId} ===`);
        console.log('Channel Title:', channelTitle);
        console.log('Channel Type:', channelType);
        console.log('Current User ID:', userId);
        console.log('Is Current User Participant:', isParticipant);
        console.log('\nParticipants:');
        participants.forEach(p => {
          console.log(`- ${p.user.username} (ID: ${p.user.id}, Active: ${p.active})`);
        });
        console.log('============================\n');
        
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

      // Only attempt to join channel via WebSocket if we're a participant
      if (isParticipant && websocketService.isConnected()) {
        websocketService.joinChannel(channelId);
      }
    } catch (error) {
      console.error('Error loading channel info:', error);
    }
  }

  async function handleJoinChat() {
    try {
      websocketService.joinChannel(channelId);
      await loadChannelInfo(); // Reload to update participant status
    } catch (error) {
      console.error('Failed to join chat:', error);
    }
  }

  async function handleLeaveChat() {
    try {
      websocketService.leaveChannel(channelId);
      isParticipant = false;
      await loadChannelInfo(); // Reload to update participant status
    } catch (error) {
      console.error('Failed to leave chat:', error);
    }
  }

  onMount(async () => {
    await loadChannelInfo();
  });

  onDestroy(() => {
    if (typingTimeout) clearTimeout(typingTimeout);
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

  $: chatTitle = channelType === 'group' ? 
    (channelTitle || 'Group Chat') : 
    (participantsList ? `Chat with ${participantsList}` : 'Loading...');

  // Add a function to handle WebSocket reconnection
  function handleWebSocketReconnected() {
    if (isParticipant && channelId) {
      websocketService.joinChannel(channelId);
    }
  }

  // Subscribe to connection status changes to handle reconnection
  connectionStatusStore.subscribe((status) => {
    connectionStatus = status;
    if (status === 'connected') {
      handleWebSocketReconnected();
    }
  });
</script>

<div class="chat-container">
  <div class="chat-header">
    <ConnectionStatus status={connectionStatus} />
    <div class="chat-info">
      <div class="chat-title-row">
        <div class="chat-title">{chatTitle}</div>
        <div class="chat-actions">
          {#if channelType === 'group'}
            {#if isParticipant}
              <Button onClick={handleLeaveChat} Class="leave-btn">Leave Chat</Button>
            {:else}
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
      <MessageList {messages} {userId} />
      <TypingIndicator users={typingUsers} {userId} />
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

  :global(.leave-btn) {
    background-color: #ef4444;
    color: white;
    padding: 0.5rem 1rem;
    border-radius: 0.375rem;
  }

  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 50;
  }

  .modal-content {
    width: 100%;
    max-width: 500px;
    margin: 1rem;
  }
</style> 