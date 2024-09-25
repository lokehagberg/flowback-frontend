<script lang="ts">
	import type { WorkGroup } from './interface';
	import Button from '$lib/Generic/Button.svelte';
	export let workGroup: WorkGroup;
</script>

<div class="bg-white dark:bg-darkobject w-full p-6 mb-6 flex justify-between items-center">
	<span class="text-primary w-[20%]">{workGroup.name}</span>
	<span class="text-gray-500 text-sm">Members: {workGroup.members} </span>

	{#if workGroup.members}
		<Button buttonStyle="warning" Class="px-3 py-1 w-[20%]">Leave</Button>
	{:else if workGroup.direct_join}
		<Button buttonStyle="primary-light" Class="px-3 py-1 w-[20%]">Ask to Join</Button>
	{:else}
		<Button buttonStyle="primary-light" Class="px-3 py-1 w-[20%]">Join</Button>
	{/if}
</div>
