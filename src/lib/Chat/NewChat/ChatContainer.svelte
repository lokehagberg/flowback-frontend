<!-- ChatContainer.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { websocketService, messagesStore, typingUsersStore, connectionStatusStore } from '../../../api/websocketService';
  import MessageList from './MessageList.svelte';
  import MessageInput from './MessageInput.svelte';
  import TypingIndicator from './TypingIndicator.svelte';
  import ConnectionStatus from './ConnectionStatus.svelte';

  export let channelId: number;
  export let userId: number;

  let typingTimeout: NodeJS.Timeout;
  let messages: any[] = [];
  let typingUsers: Set<number>;
  let connectionStatus: 'connected' | 'disconnected' | 'error';

  messagesStore.subscribe((value) => {
    messages = value;
  });

  typingUsersStore.subscribe((value) => {
    typingUsers = value;
  });

  connectionStatusStore.subscribe((value) => {
    connectionStatus = value;
  });

  onMount(() => {
    const token = localStorage.getItem('token');
    if (token) {
      websocketService.connect(token);
      websocketService.joinChannel(channelId);
    }
  });

  onDestroy(() => {
    websocketService.leaveChannel(channelId);
  });

  function handleMessageSubmit(event: CustomEvent<string>) {
    const message = event.detail;
    websocketService.sendMessage(channelId, message);
  }

  function handleTyping() {
    clearTimeout(typingTimeout);
    websocketService.sendTypingIndicator(channelId);
    
    typingTimeout = setTimeout(() => {
      // Typing timeout
    }, 3000);
  }
</script>

<div class="chat-container">
  <ConnectionStatus status={connectionStatus} />
  
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

  .messages-wrapper {
    flex-grow: 1;
    overflow-y: auto;
    padding: 1rem;
    display: flex;
    flex-direction: column;
  }
</style> 