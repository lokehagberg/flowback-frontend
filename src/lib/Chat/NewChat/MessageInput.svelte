<!-- MessageInput.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let disabled = false;

  const dispatch = createEventDispatcher<{
    message: string;
    typing: void;
  }>();

  let message = '';
  let inputElement: HTMLTextAreaElement;

  function handleInput() {
    dispatch('typing');
    
    // Auto-resize textarea
    inputElement.style.height = 'auto';
    inputElement.style.height = `${inputElement.scrollHeight}px`;
  }

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

<div class="input-container">
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

<style>
  .input-container {
    display: flex;
    gap: 0.5rem;
    padding: 1rem;
    background-color: white;
    border-top: 1px solid #dee2e6;
  }

  textarea {
    flex-grow: 1;
    padding: 0.75rem;
    border: 1px solid #dee2e6;
    border-radius: 0.5rem;
    resize: none;
    max-height: 150px;
    font-family: inherit;
    font-size: inherit;
    line-height: 1.5;
  }

  textarea:disabled {
    background-color: #e9ecef;
    cursor: not-allowed;
  }

  button {
    align-self: flex-end;
    padding: 0.75rem 1.5rem;
    background-color: #e9ecef;
    border: none;
    border-radius: 0.5rem;
    font-weight: 600;
    cursor: not-allowed;
    transition: all 0.2s ease;
  }

  button.active {
    background-color: #007bff;
    color: white;
    cursor: pointer;
  }

  button.active:hover {
    background-color: #0056b3;
  }
</style> 