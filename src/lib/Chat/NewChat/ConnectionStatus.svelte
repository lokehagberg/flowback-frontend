<!-- ConnectionStatus.svelte -->
<script lang="ts">
  import type { ConnectionStatus } from '$lib/api/websocketService';
  export let status: ConnectionStatus;
</script>

<div class="status-indicator" class:connected={status === 'connected'} class:error={status === 'error'} class:connecting={status === 'connecting'}>
  <div class="dot"></div>
  <span class="status-text">
    {#if status === 'connected'}
      Connected
    {:else if status === 'connecting'}
      Connecting...
    {:else if status === 'disconnected'}
      Disconnected
    {:else if status === 'error'}
      Connection Error
    {/if}
  </span>
</div>

<style>
  .status-indicator {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.25rem 0.5rem;
    font-size: 0.875rem;
    color: #6c757d;
  }

  .dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background-color: #dc3545;
  }

  .connected .dot {
    background-color: #28a745;
  }

  .connecting .dot {
    background-color: #ffc107;
    animation: pulse 1s infinite;
  }

  .error .dot {
    background-color: #dc3545;
  }

  .status-text {
    font-size: 0.75rem;
  }

  @keyframes pulse {
    0% { opacity: 1; }
    50% { opacity: 0.5; }
    100% { opacity: 1; }
  }
</style> 