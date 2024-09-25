<script lang="ts">
	import type { WorkingGroup } from '../interface';
	import Button from '$lib/Generic/Button.svelte';
	export let workingGroup: WorkingGroup;
</script>

<div class="bg-white dark:bg-darkobject w-full p-6 mb-6 flex justify-between items-center">
	<span class="text-primary w-[20%]">{workingGroup.name}</span>
	<span class="text-gray-500 text-sm">Members: {workingGroup.members} </span>

	{#if workingGroup.isMember}
		<Button buttonStyle="warning" Class="px-3 py-1 w-[20%]">Leave</Button>
	{:else if workingGroup.invite}
		<Button buttonStyle="primary-light" Class="px-3 py-1 w-[20%]">Ask to Join</Button>
	{:else}
		<Button buttonStyle="primary-light" Class="px-3 py-1 w-[20%]">Join</Button>
	{/if}
</div>
