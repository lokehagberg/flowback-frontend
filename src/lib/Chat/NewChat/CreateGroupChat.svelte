<script lang="ts">
  import { chat } from '$lib/api/chat';
  import Button from '$lib/Generic/Button.svelte';
  import TextInput from '$lib/Generic/TextInput.svelte';
  import { websocketService } from '$lib/api/websocketService';
  import type { User } from '$lib/api/chat';
  import { onDestroy } from 'svelte';

  export let onClose: () => void;
  
  let groupName = '';
  let selectedMembers: User[] = [];
  let searchQuery = '';
  let error = '';
  let loading = false;

  async function addUserByUsername() {
    if (!searchQuery.trim()) return;

    try {
      loading = true;
      error = '';
      const currentUserId = Number(localStorage.getItem('userId'));
      
      // Check if user is already selected
      if (selectedMembers.some(m => m.username === searchQuery.trim())) {
        error = 'User already added to group';
        loading = false;
        return;
      }

      // Get user by exact username
      const response = await chat.searchUsers(searchQuery.trim());
      
      if (response.results.length > 0) {
        const user = response.results[0]; // Should only be one result with exact match
        if (user.id === currentUserId) {
          error = 'Cannot add yourself to the group';
        } else {
          selectedMembers = [...selectedMembers, user];
          searchQuery = '';
          error = '';
        }
      } else {
        error = 'User not found. Please check the username';
      }
    } catch (err) {
      console.error('Failed to add user:', err);
      error = 'Failed to add user';
    } finally {
      loading = false;
    }
  }

  async function handleSubmit() {
    if (!groupName.trim()) {
      error = 'Please enter a group name';
      return;
    }
    if (selectedMembers.length === 0) {
      error = 'Please select at least one member';
      return;
    }

    loading = true;
    error = '';

    try {
      const response = await chat.createGroupChat(
        groupName,
        selectedMembers.map(m => m.id)
      );

      if (response.id) {
        // Join the new channel
        websocketService.joinChannel(response.id);
        onClose();
      }
    } catch (err) {
      console.error('Failed to create group chat:', err);
      error = 'Failed to create group chat';
    } finally {
      loading = false;
    }
  }

  onDestroy(() => {
    // No need to clear timeout as addUserByUsername does not use setTimeout
  });
</script>

<div class="create-group-container">
  <h2 class="title">Create Group Chat</h2>

  <form on:submit|preventDefault={handleSubmit} class="form">
    <TextInput
      label="Group Name"
      bind:value={groupName}
      placeholder="Enter group name"
      required
      autofocus
    />

    <div class="search-section">
      <form on:submit|preventDefault={addUserByUsername}>
        <TextInput
          label="Add User by Username"
          bind:value={searchQuery}
          placeholder="Enter exact username and press Enter"
          Class={loading ? 'opacity-50 cursor-not-allowed' : ''}
        />
      </form>
      
      {#if loading}
        <div class="search-status loading">
          <div class="spinner"></div>
          Adding user...
        </div>
      {/if}
    </div>

    <div class="members-section">
      <h3>Selected Members:</h3>
      {#if selectedMembers.length === 0}
        <p class="no-members">No members selected</p>
      {:else}
        <ul class="members-list">
          {#each selectedMembers as member}
            <li class="member-item">
              {member.username}
              <button
                type="button"
                class="remove-btn"
                on:click={() => {
                  selectedMembers = selectedMembers.filter(m => m.id !== member.id);
                }}
              >
                ×
              </button>
            </li>
          {/each}
        </ul>
      {/if}
    </div>

    {#if error}
      <div class="error">{error}</div>
    {/if}

    <div class="buttons">
      <Button
        type="submit"
        disabled={loading}
        Class="create-btn"
      >
        {loading ? 'Creating...' : 'Create Group'}
      </Button>
      <Button
        type="button"
        onClick={onClose}
        Class="cancel-btn"
      >
        Cancel
      </Button>
    </div>
  </form>
</div>

<style>
  .create-group-container {
    background: white;
    padding: 1.5rem;
    border-radius: 0.5rem;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  .title {
    font-size: 1.5rem;
    font-weight: 600;
    margin-bottom: 1.5rem;
    color: #111827;
  }

  .form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .search-section {
    position: relative;
    margin-bottom: 1.5rem;
  }

  .search-status {
    margin-top: 0.5rem;
    padding: 0.75rem;
    text-align: center;
    color: #6b7280;
    background: #f9fafb;
    border-radius: 0.375rem;
    font-size: 0.875rem;
  }

  .search-status.loading {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
  }

  .spinner {
    width: 1rem;
    height: 1rem;
    border: 2px solid #f3f4f6;
    border-top-color: #6b7280;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  .members-section {
    margin-top: 1rem;
  }

  .members-section h3 {
    font-size: 1rem;
    font-weight: 500;
    margin-bottom: 0.5rem;
  }

  .no-members {
    color: #6b7280;
    font-style: italic;
  }

  .members-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .member-item {
    background: #f3f4f6;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .remove-btn {
    background: none;
    border: none;
    color: #6b7280;
    cursor: pointer;
    padding: 0;
    font-size: 1.25rem;
    line-height: 1;
  }

  .remove-btn:hover {
    color: #ef4444;
  }

  .error {
    color: #ef4444;
    font-size: 0.875rem;
  }

  .buttons {
    display: flex;
    gap: 1rem;
    margin-top: 1rem;
  }

  :global(.create-btn) {
    background-color: #4f46e5;
    color: white;
  }

  :global(.cancel-btn) {
    background-color: #6b7280;
    color: white;
  }
</style> 