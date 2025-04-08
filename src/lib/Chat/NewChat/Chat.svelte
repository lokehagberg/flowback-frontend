<!-- Chat.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import ChatContainer from './ChatContainer.svelte';
  import { browser } from '$app/environment';
  import { userInfo } from '$lib/Generic/GenericFunctions';
  import { websocketService, connectionStatusStore, loadingMessagesStore } from '$lib/api/websocketService';
  import { isChatOpen } from '../ChatStore.svelte';
  import { chat } from '$lib/api/chat';
  import type { MessageChannelPreview, User, UserChatInvite } from '$lib/api/chat';
  import CreateGroupChat from './CreateGroupChat.svelte';
  import Button from '$lib/Generic/Button.svelte';
  import { faUserCircle, faUsers, faSearch, faBell } from '@fortawesome/free-solid-svg-icons';
  import Fa from 'svelte-fa';
  import ChatIcon from '$lib/assets/Chat_fill.svg';
  import { darkModeStore, getIconFilter } from '$lib/Generic/DarkMode';

  interface ExtendedMessageChannelPreview extends MessageChannelPreview {
    type: 'direct' | 'group';
    otherUser: User | null;
    isActive: boolean;
    hasUnread: boolean;
  }

  let userId: number | undefined;
  let selectedChannelId: number | undefined;
  let mounted = false;
  let visible = false;
  let availableChats: ExtendedMessageChannelPreview[] = [];
  let inactiveChats: ExtendedMessageChannelPreview[] = [];
  let pendingInvites: UserChatInvite[] = [];
  let loading = false;
  let connectionStatus: 'connecting' | 'connected' | 'disconnected' | 'error';
  let loadingMessages = false;
  let showCreateGroup = false;
  let searchQuery = '';
  let searchResults: User[] = [];
  let isSearching = false;
  let searchError = '';
  let hasUnreadMessages = false;

  const unsubscribeUser = userInfo.subscribe(info => {
    if (info?.user?.id) {
      userId = info.user.id;
      if (mounted) loadAvailableChats();
    }
  });

  const unsubscribeChat = isChatOpen.subscribe(isOpen => {
    visible = isOpen;
    if (browser) {
      websocketService.setVisibility(isOpen);
    }
  });

  connectionStatusStore.subscribe(status => {
    connectionStatus = status;
  });

  loadingMessagesStore.subscribe(isLoading => {
    loadingMessages = isLoading;
  });

  async function loadInvites() {
    try {
      const response = await chat.listChatInvites({ rejected__isnull: true });
      pendingInvites = response.results;
    } catch (error) {
      console.error('Error loading invites:', error);
    }
  }

  async function handleInviteResponse(inviteId: number, accept: boolean) {
    try {
      await chat.respondToChatInvite(inviteId, accept);
      // Refresh invites and chats
      await loadInvites();
      await loadAvailableChats();
    } catch (error) {
      console.error('Error responding to invite:', error);
    }
  }

  async function loadAvailableChats() {
    if (!userId) return;
    loading = true;
    try {
      // Load all chats with pagination
      const loadAllChats = async () => {
        let allResults = [];
        let offset = 0;
        const limit = 50;
        
        while (true) {
          const response = await chat.getChannelPreviews({ 
            limit,
            offset
          });
          
          // For each chat, get the participants to determine type and other user
          const chatsWithParticipants = await Promise.all(
            response.results.map(async (chatPreview) => {
              try {
                const participantsResponse = await chat.getParticipants(chatPreview.channel_id);
                const participants = participantsResponse.results || [];
                const otherUser = participants.find(p => p.user && p.user.id !== userId)?.user || null;
                const currentUserParticipant = participants.find(p => p.user.id === userId);
                const isActive = currentUserParticipant?.active ?? false;
                const hasUnread = isUnread(chatPreview);
                
                return {
                  ...chatPreview,
                  type: participants.length <= 2 ? ('direct' as const) : ('group' as const),
                  otherUser,
                  isActive,
                  hasUnread
                };
              } catch (error) {
                console.error('Error getting participants for chat:', error);
                return {
                  ...chatPreview,
                  type: chatPreview.participants <= 2 ? ('direct' as const) : ('group' as const),
                  otherUser: null,
                  isActive: false,
                  hasUnread: false
                };
              }
            })
          );
          
          allResults.push(...chatsWithParticipants);
          
          if (!response.next || response.results.length < limit) {
            break;
          }
          
          offset += limit;
        }
        
        return allResults;
      };

      const allChats = await loadAllChats();
      
      // Split chats into active and inactive
      availableChats = allChats
        .filter(chat => chat.isActive)
        .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
      
      inactiveChats = allChats
        .filter(chat => !chat.isActive)
        .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());

      // Update global unread status
      hasUnreadMessages = availableChats.some(chat => chat.hasUnread) || pendingInvites.length > 0;

    } catch (error) {
      console.error('Error loading chats:', error);
    } finally {
      loading = false;
    }
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

  async function rejoinChat(channelId: number) {
    try {
      websocketService.joinChannel(channelId);
      await loadAvailableChats();
    } catch (error) {
      console.error('Error rejoining chat:', error);
    }
  }

  async function searchUsers() {
    if (!searchQuery.trim()) {
      searchResults = [];
      return;
    }

    isSearching = true;
    searchError = '';

    try {
      const response = await chat.searchUsers(searchQuery);
      searchResults = response.results.filter(user => user.id !== userId);
    } catch (error) {
      console.error('Error searching users:', error);
      searchError = 'Failed to search users';
    } finally {
      isSearching = false;
    }
  }

  async function startDirectChat(targetUser: User) {
    try {
      const response = await chat.getChatChannel([targetUser.id]);
      selectedChannelId = response.id;
      searchQuery = '';
      searchResults = [];
      await loadAvailableChats();
    } catch (error) {
      console.error('Error starting DM:', error);
    }
  }

  onMount(() => {
    mounted = true;
    if (browser) {
      const token = localStorage.getItem('token');
      if (token && !websocketService.isConnected()) {
        websocketService.connect(token);
      }
      loadAvailableChats();
      loadInvites();
    }
  });

  onDestroy(() => {
    unsubscribeUser();
    unsubscribeChat();
  });

  function formatChatTitle(chat: ExtendedMessageChannelPreview | null) {
    if (!chat) return 'Unknown Chat';
    
    if (chat.type === 'direct') {
      // For DMs, use the other user's name
      return `DM with ${chat.otherUser?.username || 'Unknown User'}`;
    }
    
    // For group chats, use channel title or default
    return chat.channel_title || 'Group Chat';
  }

  function getLastMessagePreview(chat: ExtendedMessageChannelPreview) {
    if (!chat.message) return 'No messages yet';
    if (!chat.user) return chat.message;
    
    // For DMs, don't show the username in preview if it's the other user
    if (chat.type === 'direct' && chat.user.id === chat.otherUser?.id) {
      return chat.message;
    }
    
    return `${chat.user.username}: ${chat.message}`;
  }

  // Update user data when viewing a chat
  async function updateUserData(channelId: number) {
    try {
      const now = new Date().toISOString();
      await chat.updateUserChannelData({
        channel_id: channelId,
        timestamp: now,
        closed_at: now
      });
      await loadAvailableChats(); // Refresh chat list to update unread status
    } catch (error) {
      console.error('Error updating user data:', error);
    }
  }

  // Check for unread messages in a chat preview
  function isUnread(preview: MessageChannelPreview): boolean {
    return preview.timestamp === null || new Date(preview.timestamp) < new Date(preview.created_at);
  }

  // Update the chat selection handler
  function selectChat(channelId: number) {
    selectedChannelId = channelId;
    updateUserData(channelId);
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
      <div class="chat-header">
        <div class="header-content">
          <div class="header-top">
            <h2 class="text-xl font-semibold">Chats</h2>
            <div class="header-actions">
              <button class="icon-button" title="Create Group Chat" on:click={() => showCreateGroup = true}>
                <Fa icon={faUsers} />
              </button>
            </div>
          </div>
          <div class="search-bar">
            <div class="search-input-wrapper">
              <input
                type="text"
                bind:value={searchQuery}
                on:input={searchUsers}
                placeholder="Search for a user to start a DM..."
                class="w-full p-2 pl-10 pr-8 rounded-full border border-gray-300 dark:border-gray-600 dark:bg-gray-700"
              />
              <div class="search-icon left">
                <Fa icon={faSearch} />
              </div>
              {#if isSearching}
                <div class="search-icon right">
                  <div class="loading-spinner" />
                </div>
              {/if}
            </div>
            {#if searchQuery && searchResults.length > 0}
              <div class="search-results">
                {#each searchResults as user}
                  <button
                    class="search-result-item"
                    on:click={() => startDirectChat(user)}
                  >
                    <div class="user-icon">
                      <Fa icon={faUserCircle} />
                    </div>
                    <div class="user-info">
                      <span class="username">{user.username}</span>
                    </div>
                  </button>
                {/each}
              </div>
            {:else if searchQuery && !isSearching}
              <div class="search-results">
                <div class="no-results">
                  {searchError || 'No users found'}
                </div>
              </div>
            {/if}
          </div>
        </div>
      </div>
      <div class="chat-list">
        {#if loading}
          <div class="loading-indicator">Loading chats...</div>
        {:else}
          {#if pendingInvites.length > 0}
            <div class="invites-section">
              <h3 class="section-title">Pending Invites</h3>
              {#each pendingInvites as invite}
                <div class="invite-item">
                  <span>{invite.message_channel_name}</span>
                  <div class="invite-actions">
                    <Button 
                      onClick={() => handleInviteResponse(invite.id, true)}
                      Class="accept-btn"
                    >
                      Accept
                    </Button>
                    <Button 
                      onClick={() => handleInviteResponse(invite.id, false)}
                      Class="reject-btn"
                    >
                      Reject
                    </Button>
                  </div>
                </div>
              {/each}
            </div>
          {/if}

          <div class="active-chats">
            <h3 class="section-title">Active Chats</h3>
            {#each availableChats as chat}
              <div 
                class="chat-item"
                class:selected={selectedChannelId === chat.channel_id}
                class:dm={chat.type === 'direct'}
                class:group={chat.type === 'group'}
                class:unread={chat.hasUnread}
                on:click={() => selectChat(chat.channel_id)}
              >
                <div class="chat-item-content">
                  <div class="chat-item-header">
                    <div class="chat-type-icon">
                      <Fa icon={chat.type === 'direct' ? faUserCircle : faUsers} />
                    </div>
                    <div class="chat-item-title">{formatChatTitle(chat)}</div>
                  </div>
                  <div class="chat-item-preview">{getLastMessagePreview(chat)}</div>
                </div>
              </div>
            {/each}
          </div>

          {#if inactiveChats.length > 0}
            <div class="inactive-chats">
              <h3 class="section-title">Inactive Chats</h3>
              {#each inactiveChats as chat}
                <div 
                  class="chat-item inactive"
                  class:dm={chat.type === 'direct'}
                  class:group={chat.type === 'group'}
                >
                  <div class="chat-item-content">
                    <div class="chat-item-header">
                      <div class="chat-type-icon">
                        <Fa icon={chat.type === 'direct' ? faUserCircle : faUsers} />
                      </div>
                      <div class="chat-item-title">{formatChatTitle(chat)}</div>
                    </div>
                    <div class="chat-item-preview">{getLastMessagePreview(chat)}</div>
                  </div>
                  <Button 
                    onClick={() => rejoinChat(chat.channel_id)}
                    Class="rejoin-btn"
                  >
                    Rejoin
                  </Button>
                </div>
              {/each}
            </div>
          {/if}
        {/if}
      </div>
    {/if}
  </div>
{/if}

{#if showCreateGroup}
  <div class="modal-overlay">
    <div class="modal-content">
      <CreateGroupChat onClose={() => showCreateGroup = false} />
    </div>
  </div>
{/if}

<button
  class="chat-toggle"
  class:has-notification={hasUnreadMessages}
  on:click={() => isChatOpen.set(!visible)}
  aria-label={visible ? 'Close chat' : 'Open chat'}
>
  <img
    src={ChatIcon}
    class="icon"
    style="filter: {getIconFilter(true, 'white')}"
    alt={visible ? 'close chat' : 'open chat'}
  />
  <span class="sr-only">Toggle chat</span>
</button>

<style>
  .chat-wrapper {
    position: fixed;
    bottom: 20px;
    right: 88px;
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
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    border-bottom: 1px solid #e5e7eb;
  }

  .chat-list-header h2 {
    font-size: 1.25rem;
    font-weight: 600;
    color: #111827;
    margin: 0;
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
    padding: 0.75rem;
    border-radius: 0.375rem;
    cursor: pointer;
    display: flex;
    justify-content: space-between;
    align-items: center;
    transition: all 0.2s ease;
    border-left: 3px solid transparent;
  }

  .chat-item.dm {
    border-left-color: #60a5fa; /* Blue for DMs */
  }

  .chat-item.group {
    border-left-color: #10b981; /* Green for groups */
  }

  .chat-item:hover {
    background: #f3f4f6;
  }

  .chat-item.selected {
    background: #e5e7eb;
  }

  .chat-item.inactive {
    opacity: 0.7;
  }

  .chat-item.unread {
    background-color: #f3f4f6;
  }

  .chat-item-content {
    flex: 1;
    min-width: 0; /* Enables text truncation */
  }

  .chat-item-header {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 4px;
  }

  .chat-type-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 24px;
    height: 24px;
    color: #6b7280;
  }

  .chat-item.dm .chat-type-icon {
    color: #60a5fa;
  }

  .chat-item.group .chat-type-icon {
    color: #10b981;
  }

  .chat-item-title {
    font-weight: 500;
    color: #111827;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .chat-item-preview {
    font-size: 0.875rem;
    color: #6b7280;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    padding-left: calc(24px + 0.5rem); /* Align with title text */
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

  .chat-toggle.has-notification::after {
    content: '';
    position: absolute;
    top: 0;
    right: 0;
    width: 12px;
    height: 12px;
    background-color: #ef4444;
    border-radius: 50%;
    border: 2px solid white;
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

  :global(.create-group-btn) {
    background-color: #10b981;
    color: white;
    padding: 0.5rem 1rem;
    border-radius: 0.375rem;
    font-size: 0.875rem;
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
    z-index: 2000;
  }

  .modal-content {
    width: 100%;
    max-width: 500px;
    margin: 1rem;
    background: white;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  }

  .loading-indicator {
    text-align: center;
    color: #6b7280;
    padding: 1rem;
  }

  .invites-section {
    background: #f3f4f6;
    border-radius: 0.5rem;
    padding: 1rem;
  }

  .invite-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem;
    background: white;
    border-radius: 0.375rem;
    margin-bottom: 0.5rem;
  }

  .invite-actions {
    display: flex;
    gap: 0.5rem;
  }

  :global(.accept-btn) {
    background-color: #10b981;
    color: white;
  }

  :global(.reject-btn) {
    background-color: #ef4444;
    color: white;
  }

  :global(.rejoin-btn) {
    background-color: #6b7280;
    color: white;
    font-size: 0.875rem;
    padding: 0.25rem 0.75rem;
  }

  .header-content {
    padding: 0.75rem;
    border-bottom: 1px solid #e5e7eb;
  }

  .header-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.75rem;
  }

  .header-actions {
    display: flex;
    gap: 0.5rem;
  }

  .icon-button {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background-color: #f3f4f6;
    color: #4b5563;
    transition: all 0.2s;
  }

  .icon-button:hover {
    background-color: #e5e7eb;
    color: #374151;
  }

  .search-bar {
    position: relative;
  }

  .search-input-wrapper {
    position: relative;
  }

  .search-input-wrapper input {
    font-size: 0.875rem;
  }

  .search-icon {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    color: #6b7280;
    font-size: 0.875rem;
  }

  .search-icon.left {
    left: 0.75rem;
  }

  .search-icon.right {
    right: 0.75rem;
  }

  .search-results {
    position: absolute;
    top: calc(100% + 4px);
    left: 0;
    right: 0;
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 0.5rem;
    max-height: 200px;
    overflow-y: auto;
    z-index: 50;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  }

  .search-result-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 0.75rem;
    width: 100%;
    text-align: left;
    transition: background-color 0.2s;
  }

  .search-result-item:hover {
    background-color: #f3f4f6;
  }

  .user-icon {
    color: #6b7280;
    width: 24px;
    height: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .no-results {
    padding: 0.75rem;
    color: #6b7280;
    text-align: center;
    font-size: 0.875rem;
  }

  /* Dark mode adjustments */
  :global(.dark) .icon-button {
    background-color: #374151;
    color: #9ca3af;
  }

  :global(.dark) .icon-button:hover {
    background-color: #4b5563;
    color: #e5e7eb;
  }

  :global(.dark) .search-results {
    background: #1f2937;
    border-color: #374151;
  }

  :global(.dark) .search-result-item:hover {
    background-color: #374151;
  }

  :global(.dark) .username {
    color: #e5e7eb;
  }

  .chat-button {
    position: fixed;
    bottom: 1rem;
    left: 1rem;
    z-index: 50;
    padding: 1rem;
    background-color: white;
    border-radius: 50%;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    transition: all 0.2s;
  }

  .chat-button.has-notification::after {
    content: '';
    position: absolute;
    top: 0;
    right: 0;
    width: 12px;
    height: 12px;
    background-color: #ef4444;
    border-radius: 50%;
    border: 2px solid white;
  }

  .chat-preview {
    padding: 0.75rem;
    cursor: pointer;
    transition: background-color 0.2s;
    border-bottom: 1px solid #e5e7eb;
    position: relative;
  }

  .chat-preview:hover {
    background-color: #f3f4f6;
  }

  .chat-preview.selected {
    background-color: #e5e7eb;
  }

  .chat-preview.unread::before {
    content: '';
    position: absolute;
    left: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 4px;
    height: 4px;
    background-color: #ef4444;
    border-radius: 50%;
  }

  .chat-preview-content {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .unread-indicator {
    width: 8px;
    height: 8px;
    background-color: #ef4444;
    border-radius: 50%;
    margin-left: auto;
  }
</style> 