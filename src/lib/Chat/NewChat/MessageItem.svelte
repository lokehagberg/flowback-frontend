<!-- MessageItem.svelte -->
<script lang="ts">
  import type { Message } from '$lib/api/websocketService';
  import { formatDistanceToNow } from 'date-fns';

  export let message: Message;
  export let isOwnMessage: boolean;

  $: formattedTime = formatDistanceToNow(new Date(message.created_at), { addSuffix: true });
</script>

<div class="message" class:own-message={isOwnMessage}>
  {#if !isOwnMessage}
    <div class="username">{message.user.username}</div>
  {/if}
  <div class="content">
    <p class="text">{message.message}</p>
    <span class="time">{formattedTime}</span>
  </div>
</div>

<style>
  .message {
    max-width: 70%;
    margin-bottom: 0.5rem;
  }

  .username {
    font-size: 0.875rem;
    color: #666;
    margin-bottom: 0.25rem;
  }

  .content {
    background-color: #e9ecef;
    padding: 0.75rem;
    border-radius: 1rem;
    position: relative;
  }

  .own-message .content {
    background-color: #007bff;
    color: white;
  }

  .text {
    margin: 0;
    white-space: pre-wrap;
    word-break: break-word;
  }

  .time {
    font-size: 0.75rem;
    color: #999;
    margin-top: 0.25rem;
    display: block;
  }

  .own-message .time {
    color: rgba(255, 255, 255, 0.8);
  }
</style> 