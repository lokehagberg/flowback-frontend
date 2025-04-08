<!-- TypingIndicator.svelte -->
<script lang="ts">
  import { typingUsersStore } from '$lib/api/websocketService';
  import { onMount } from 'svelte';
  import { chat } from '$lib/api/chat';
  import type { User } from '$lib/api/chat';
  
  export let userId: number;
  
  let typingUsers = new Set<number>();
  let typingUserInfo = new Map<number, User>();
  
  // Subscribe to typing users store
  typingUsersStore.subscribe(users => {
    typingUsers = users;
    // Fetch user info for any new typing users
    Array.from(users).forEach(async (id) => {
      if (!typingUserInfo.has(id)) {
        try {
          const response = await chat.searchUsers(`id=${id}`);
          if (response.results && response.results.length > 0) {
            typingUserInfo.set(id, response.results[0]);
            typingUserInfo = typingUserInfo; // trigger reactivity
          }
        } catch (error) {
          console.error('Error fetching user info:', error);
        }
      }
    });
  });

  function formatTypingMessage(users: Set<number>) {
    const typingUsernames = Array.from(users)
      .filter(id => id !== userId)
      .map(id => typingUserInfo.get(id)?.username || 'Someone')
      .filter(username => username);

    if (typingUsernames.length === 0) return '';
    if (typingUsernames.length === 1) return `${typingUsernames[0]} is typing...`;
    if (typingUsernames.length === 2) return `${typingUsernames[0]} and ${typingUsernames[1]} are typing...`;
    return 'Several people are typing...';
  }
</script>

{#if Array.from(typingUsers).filter(id => id !== userId).length > 0}
  <div class="typing-indicator">
    <div class="dots">
      <span class="dot" />
      <span class="dot" />
      <span class="dot" />
    </div>
    <span class="text">
      {formatTypingMessage(typingUsers)}
    </span>
  </div>
{/if}

<style>
  .typing-indicator {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem;
    color: #666;
    font-size: 0.875rem;
  }

  .dots {
    display: flex;
    gap: 0.25rem;
  }

  .dot {
    width: 6px;
    height: 6px;
    background-color: #666;
    border-radius: 50%;
    animation: bounce 1.4s infinite ease-in-out;
  }

  .dot:nth-child(1) {
    animation-delay: -0.32s;
  }

  .dot:nth-child(2) {
    animation-delay: -0.16s;
  }

  @keyframes bounce {
    0%, 80%, 100% {
      transform: scale(0);
    }
    40% {
      transform: scale(1);
    }
  }

  .text {
    font-style: italic;
  }
</style> 