<!-- TypingIndicator.svelte -->
<script lang="ts">
  export let users: Set<number>;
  export let userId: number;

  $: typingUsers = Array.from(users).filter(id => id !== userId);
</script>

{#if typingUsers.length > 0}
  <div class="typing-indicator">
    <div class="dots">
      <span class="dot" />
      <span class="dot" />
      <span class="dot" />
    </div>
    <span class="text">
      {#if typingUsers.length === 1}
        Someone is typing...
      {:else if typingUsers.length === 2}
        Multiple people are typing...
      {:else}
        Several people are typing...
      {/if}
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