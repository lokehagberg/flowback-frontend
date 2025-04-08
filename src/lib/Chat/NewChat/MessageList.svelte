<!-- MessageList.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import { websocketService } from '$lib/api/websocketService';
  import type { Message } from '$lib/api/chat';
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
    background-color: rgba(156, 163, 175, 0.3);
    border-radius: 3px;
  }

  :global(.dark) .messages-container::-webkit-scrollbar-thumb {
    background-color: rgba(156, 163, 175, 0.2);
  }

  .messages-container::-webkit-scrollbar-thumb:hover {
    background-color: rgba(156, 163, 175, 0.5);
  }

  :global(.dark) .messages-container::-webkit-scrollbar-thumb:hover {
    background-color: rgba(156, 163, 175, 0.3);
  }

  .message-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .message {
    display: flex;
    gap: 0.5rem;
    padding: 0.75rem;
    border-radius: 0.5rem;
    background-color: #f3f4f6;
    max-width: 80%;
  }

  :global(.dark) .message {
    background-color: #2d3748;
  }

  .message.own {
    margin-left: auto;
    background-color: #dbeafe;
  }

  :global(.dark) .message.own {
    background-color: #1e40af;
  }

  .message-content {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .message-header {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .username {
    font-weight: 500;
    color: #111827;
  }

  :global(.dark) .username {
    color: #f3f4f6;
  }

  .timestamp {
    font-size: 0.75rem;
    color: #6b7280;
  }

  :global(.dark) .timestamp {
    color: #9ca3af;
  }

  .message-text {
    color: #1f2937;
    white-space: pre-wrap;
    word-break: break-word;
  }

  :global(.dark) .message-text {
    color: #e5e7eb;
  }

  .message.own .message-text {
    color: #1f2937;
  }

  :global(.dark) .message.own .message-text {
    color: #f3f4f6;
  }

  .user-avatar {
    width: 2rem;
    height: 2rem;
    border-radius: 50%;
    background-color: #e5e7eb;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #6b7280;
  }

  :global(.dark) .user-avatar {
    background-color: #4b5563;
    color: #9ca3af;
  }
</style> 