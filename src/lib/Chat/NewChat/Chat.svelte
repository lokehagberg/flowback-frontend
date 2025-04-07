<!-- Chat.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import ChatContainer from './ChatContainer.svelte';
  import { browser } from '$app/environment';
  import { userInfo } from '$lib/Generic/GenericFunctions';
  import { websocketService, connectionStatusStore, loadingMessagesStore } from '$lib/api/websocketService';
  import { isChatOpen } from '../ChatStore.svelte';
  import { chat } from '$lib/api/chat';
  import type { MessageChannelPreview } from '$lib/api/chat';

  interface ExtendedMessageChannelPreview extends MessageChannelPreview {
    type: 'direct' | 'group';
  }

  let userId: number | undefined;
  let selectedChannelId: number | undefined;
  let mounted = false;
  let visible = false;
  let availableChats: ExtendedMessageChannelPreview[] = [];
  let loading = false;
  let connectionStatus: 'connecting' | 'connected' | 'disconnected' | 'error';
  let loadingMessages = false;

  const unsubscribeUser = userInfo.subscribe(info => {
    if (info?.user?.id) {
      userId = info.user.id;
      if (mounted) loadAvailableChats();
    }
  });

  const unsubscribeChat = isChatOpen.subscribe(isOpen => {
    visible = isOpen;
  });

  connectionStatusStore.subscribe(status => {
    connectionStatus = status;
  });

  loadingMessagesStore.subscribe(isLoading => {
    loadingMessages = isLoading;
  });

  async function loadAvailableChats() {
    if (!userId) return;
    loading = true;
    try {
      // Load all chats with pagination
      const loadAllChats = async (origin: string) => {
        let allResults = [];
        let offset = 0;
        const limit = 50;
        
        while (true) {
          const response = await chat.getChannelPreviews({ 
            origin_names: origin,
            limit,
            offset
          });
          
          allResults.push(...response.results);
          
          if (!response.next || response.results.length < limit) {
            break;
          }
          
          offset += limit;
        }
        
        return allResults;
      };

      const [directChats, groupChats] = await Promise.all([
        loadAllChats('direct'),
        loadAllChats('group')
      ]);
      
      availableChats = [
        ...directChats.map(chat => ({ ...chat, type: 'direct' as const })),
        ...groupChats.map(chat => ({ ...chat, type: 'group' as const }))
      ].sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
    } catch (error) {
      console.error('Error loading chats:', error);
    }
    loading = false;
  }

  async function startNewChat(targetUserId: number) {
    try {
      const response = await chat.getChatChannel([targetUserId]);
      selectedChannelId = response.id;
      await loadAvailableChats();
    } catch (error) {
      console.error('Error starting chat:', error);
    }
  }

  onMount(() => {
    mounted = true;
    if (browser) {
      const token = localStorage.getItem('token');
      if (token) {
        websocketService.connect(token);
        loadAvailableChats();
      }
    }
  });

  onDestroy(() => {
    unsubscribeUser();
    unsubscribeChat();
    websocketService.disconnect();
  });

  function formatChatTitle(chat: ExtendedMessageChannelPreview) {
    if (chat.type === 'direct') {
      return `Chat with ${chat.user.username}`;
    } else {
      return chat.channel_title || 'Group Chat';
    }
  }

  function getLastMessagePreview(chat: ExtendedMessageChannelPreview) {
    if (!chat.message) return 'No messages yet';
    return `${chat.user.username}: ${chat.message}`;
  }
</script>

{#if mounted && browser && userId && visible}
  <div class="chat-wrapper">
    {#if selectedChannelId}
      <div class="chat-header">
        <button 
          class="back-button"
          on:click={() => selectedChannelId = undefined}
        >
          ← Back to chats
        </button>
      </div>
      {#if connectionStatus === 'connecting' || loadingMessages}
        <div class="loading-overlay">
          <div class="loading-spinner"></div>
          <p>Loading messages...</p>
        </div>
      {:else if connectionStatus === 'error'}
        <div class="error-message">
          Connection error. Trying to reconnect...
        </div>
      {:else if connectionStatus === 'disconnected'}
        <div class="error-message">
          Disconnected. Reconnecting...
        </div>
      {/if}
      <ChatContainer userId={userId} channelId={selectedChannelId} />
    {:else}
      <div class="chat-list">
        <h3 class="chat-list-header">Your Chats</h3>
        {#if loading}
          <div class="loading">Loading chats...</div>
        {:else if availableChats.length === 0}
          <div class="no-chats">No active chats</div>
        {:else}
          <div class="chat-sections">
            <div class="chat-section">
              <h4 class="chat-section-header">Direct Messages</h4>
              {#each availableChats.filter(c => c.type === 'direct') as chat (chat.id)}
                <button
                  class="chat-item"
                  on:click={() => selectedChannelId = chat.channel_id}
                >
                  <div class="chat-item-title">
                    {formatChatTitle(chat)}
                  </div>
                  <div class="chat-item-preview">
                    {getLastMessagePreview(chat)}
                  </div>
                </button>
              {/each}
            </div>
            
            <div class="chat-section">
              <h4 class="chat-section-header">Group Chats</h4>
              {#each availableChats.filter(c => c.type === 'group') as chat (chat.id)}
                <button
                  class="chat-item"
                  on:click={() => selectedChannelId = chat.channel_id}
                >
                  <div class="chat-item-title">
                    {formatChatTitle(chat)}
                  </div>
                  <div class="chat-item-preview">
                    {getLastMessagePreview(chat)}
                  </div>
                </button>
              {/each}
            </div>
          </div>
        {/if}
      </div>
    {/if}
  </div>
{/if}

<button
  class="chat-toggle"
  on:click={() => isChatOpen.set(!visible)}
  aria-label={visible ? 'Close chat' : 'Open chat'}
>
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="icon">
    <path d="M4.913 2.658c2.075-.27 4.19-.408 6.337-.408 2.147 0 4.262.139 6.337.408 1.922.25 3.291 1.861 3.405 3.727a4.403 4.403 0 00-1.032-.211 50.89 50.89 0 00-8.42 0c-2.358.196-4.04 2.19-4.04 4.434v4.286a4.47 4.47 0 002.433 3.984L7.28 21.53A.75.75 0 016 21v-4.03a48.527 48.527 0 01-1.087-.128C2.905 16.58 1.5 14.833 1.5 12.862V6.638c0-1.97 1.405-3.718 3.413-3.979z" />
    <path d="M15.75 7.5c-1.376 0-2.739.057-4.086.169C10.124 7.797 9 9.103 9 10.609v4.285c0 1.507 1.128 2.814 2.67 2.94 1.243.102 2.5.157 3.768.165l2.782 2.781a.75.75 0 001.28-.53v-2.39l.33-.026c1.542-.125 2.67-1.433 2.67-2.94v-4.286c0-1.505-1.125-2.811-2.664-2.94A49.392 49.392 0 0015.75 7.5z" />
  </svg>
  {#if visible}
    <span class="sr-only">Close chat</span>
  {:else}
    <span class="sr-only">Open chat</span>
  {/if}
</button>

<style>
  .chat-wrapper {
    position: fixed;
    bottom: 20px;
    right: 20px;
    width: 400px;
    height: 600px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    z-index: 1000;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }

  .chat-header {
    padding: 12px;
    border-bottom: 1px solid #e5e7eb;
  }

  .back-button {
    background: none;
    border: none;
    color: #374151;
    font-size: 14px;
    cursor: pointer;
    padding: 4px 8px;
    border-radius: 4px;
  }

  .back-button:hover {
    background: #f3f4f6;
  }

  .chat-list {
    flex: 1;
    overflow-y: auto;
    padding: 16px;
  }

  .chat-list-header {
    margin: 0 0 16px;
    font-size: 18px;
    font-weight: 600;
    color: #111827;
  }

  .chat-sections {
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  .chat-section {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .chat-section-header {
    font-size: 14px;
    font-weight: 500;
    color: #6b7280;
    margin: 0 0 8px;
    padding-bottom: 4px;
    border-bottom: 1px solid #e5e7eb;
  }

  .chat-item {
    width: 100%;
    padding: 12px;
    background: none;
    border: none;
    border-radius: 6px;
    text-align: left;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .chat-item:hover {
    background: #f9fafb;
  }

  .chat-item-title {
    font-weight: 500;
    color: #111827;
    margin-bottom: 4px;
  }

  .chat-item-preview {
    font-size: 14px;
    color: #6b7280;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .loading, .no-chats {
    text-align: center;
    color: #6b7280;
    padding: 24px;
  }

  .loading-overlay {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(255, 255, 255, 0.9);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 16px;
    z-index: 10;
  }

  .loading-spinner {
    width: 40px;
    height: 40px;
    border: 3px solid #f3f3f3;
    border-top: 3px solid #3498db;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }

  .error-message {
    text-align: center;
    color: #ef4444;
    padding: 12px;
    background: #fee2e2;
    margin: 8px;
    border-radius: 4px;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  .chat-toggle {
    position: fixed;
    bottom: 20px;
    right: 20px;
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background: #007bff;
    color: white;
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    transition: all 0.2s ease;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  }

  .chat-toggle:hover {
    background: #0056b3;
    transform: scale(1.05);
  }

  .chat-toggle:active {
    transform: scale(0.95);
  }

  .icon {
    width: 24px;
    height: 24px;
  }

  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border: 0;
  }

  @media (max-width: 480px) {
    .chat-wrapper {
      width: calc(100% - 40px);
      height: calc(100vh - 120px);
    }
  }
</style> 