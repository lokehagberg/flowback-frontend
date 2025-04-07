<!-- MessageList.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import type { Message } from '$lib/api/websocketService';
  import MessageItem from './MessageItem.svelte';

  export let messages: Message[] = [];
  export let userId: number;

  let messagesContainer: HTMLDivElement;
  let shouldAutoScroll = true;
  let lastScrollTop = 0;

  $: sortedMessages = messages.sort((a, b) => 
    new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
  );

  onMount(() => {
    scrollToBottom();
  });

  $: if (messages.length) {
    if (shouldAutoScroll) {
      scrollToBottom();
    }
  }

  function handleScroll(event: Event) {
    const target = event.target as HTMLDivElement;
    const isScrollingUp = target.scrollTop < lastScrollTop;
    const isNearBottom = target.scrollHeight - target.scrollTop - target.clientHeight < 100;
    
    shouldAutoScroll = !isScrollingUp && isNearBottom;
    lastScrollTop = target.scrollTop;
  }

  function scrollToBottom() {
    if (messagesContainer) {
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
  }
</script>

<div 
  class="messages-container" 
  bind:this={messagesContainer}
  on:scroll={handleScroll}
>
  {#each sortedMessages as message (message.id)}
    <div class="message-wrapper" class:own-message={message.user.id === userId}>
      <MessageItem {message} isOwnMessage={message.user.id === userId} />
    </div>
  {/each}
</div>

<style>
  .messages-container {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    overflow-y: auto;
    padding-right: 0.5rem;
    height: 100%;
  }

  .message-wrapper {
    display: flex;
    width: 100%;
  }

  .message-wrapper.own-message {
    justify-content: flex-end;
  }

  /* Scrollbar styling */
  .messages-container::-webkit-scrollbar {
    width: 6px;
  }

  .messages-container::-webkit-scrollbar-track {
    background: transparent;
  }

  .messages-container::-webkit-scrollbar-thumb {
    background-color: rgba(0, 0, 0, 0.2);
    border-radius: 3px;
  }

  .messages-container::-webkit-scrollbar-thumb:hover {
    background-color: rgba(0, 0, 0, 0.3);
  }
</style> 