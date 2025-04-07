<!-- ConnectionStatus.svelte -->
<script lang="ts">
  export let status: 'connected' | 'disconnected' | 'error';

  $: statusText = {
    connected: 'Connected',
    disconnected: 'Disconnected',
    error: 'Connection Error'
  }[status];

  $: statusClass = {
    connected: 'success',
    disconnected: 'warning',
    error: 'error'
  }[status];
</script>

{#if status !== 'connected'}
  <div class="status-bar {status === 'disconnected' ? 'warning' : ''} {status === 'error' ? 'error' : ''}">
    <div class="status-indicator {statusClass}" />
    <span>{statusText}</span>
  </div>
{/if}

<style>
  .status-bar {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    background-color: #fff3cd;
    color: #856404;
    font-size: 0.875rem;
  }

  .status-bar.error {
    background-color: #f8d7da;
    color: #721c24;
  }

  .status-indicator {
    width: 8px;
    height: 8px;
    border-radius: 50%;
  }

  .status-indicator.warning {
    background-color: #ffc107;
  }

  .status-indicator.error {
    background-color: #dc3545;
  }

  .status-indicator.success {
    background-color: #28a745;
  }
</style> 