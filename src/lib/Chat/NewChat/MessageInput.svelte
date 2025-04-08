<!-- MessageInput.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { onDestroy } from 'svelte';

  export let disabled = false;

  const dispatch = createEventDispatcher<{
    message: string;
    typing: void;
  }>();

  let message = '';
  let inputElement: HTMLTextAreaElement;
  let typingTimeout: ReturnType<typeof setTimeout>;

  function handleInput() {
    if (typingTimeout) clearTimeout(typingTimeout);
    
    dispatch('typing');
    
    // Auto-resize textarea
    inputElement.style.height = 'auto';
    inputElement.style.height = `${inputElement.scrollHeight}px`;
    
    // Set a new typing timeout
    typingTimeout = setTimeout(() => {
      dispatch('typing');
    }, 2000);
  }

  onDestroy(() => {
    if (typingTimeout) clearTimeout(typingTimeout);
  });

  function handleKeyDown(event: KeyboardEvent) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      handleSubmit();
    }
  }

  function handleSubmit() {
    if (message.trim() && !disabled) {
      dispatch('message', message.trim());
      message = '';
      inputElement.style.height = 'auto';
    }
  }
</script>

<div class="message-input-container">
  <div class="input-wrapper">
    <textarea
      bind:this={inputElement}
      bind:value={message}
      on:input={handleInput}
      on:keydown={handleKeyDown}
      placeholder="Type a message..."
      rows="1"
      {disabled}
    />
    <button 
      on:click={handleSubmit} 
      disabled={!message.trim() || disabled}
      class:active={message.trim() && !disabled}
    >
      Send
    </button>
  </div>
</div>

<style>
  .message-input-container {
    padding: 1rem;
    border-top: 1px solid #e5e7eb;
    background-color: white;
  }

  :global(.dark) .message-input-container {
    background-color: #111827;
    border-color: #374151;
  }

  .input-wrapper {
    display: flex;
    gap: 0.5rem;
    align-items: flex-end;
  }

  textarea {
    flex-grow: 1;
    resize: none;
    border: 1px solid #e5e7eb;
    border-radius: 0.375rem;
    padding: 0.5rem;
    font-size: 0.875rem;
    line-height: 1.25rem;
    min-height: 2.5rem;
    max-height: 10rem;
    background-color: white;
    color: #111827;
  }

  :global(.dark) textarea {
    background-color: #1f2937;
    border-color: #374151;
    color: #e5e7eb;
  }

  textarea:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
  }

  :global(.dark) textarea:focus {
    border-color: #4f46e5;
    box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.1);
  }

  textarea:disabled {
    background-color: #f3f4f6;
    cursor: not-allowed;
  }

  :global(.dark) textarea:disabled {
    background-color: #374151;
  }

  .send-button {
    padding: 0.5rem 1rem;
    background-color: #3b82f6;
    color: white;
    border: none;
    border-radius: 0.375rem;
    font-size: 0.875rem;
    cursor: pointer;
    transition: all 0.2s;
  }

  :global(.dark) .send-button {
    background-color: #4f46e5;
  }

  .send-button:hover {
    background-color: #2563eb;
  }

  :global(.dark) .send-button:hover {
    background-color: #4338ca;
  }

  .send-button:disabled {
    background-color: #9ca3af;
    cursor: not-allowed;
  }

  :global(.dark) .send-button:disabled {
    background-color: #4b5563;
  }
</style> 