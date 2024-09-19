<script lang="ts">
	import Button from '$lib/Generic/Button.svelte';
	import Filter from '$lib/Generic/Filter.svelte';
	import type { WorkingGroup } from './interface';

	let workingGroups: WorkingGroup[] = [
		{ name: 'hi :3', isMember: false, invite: false, members: 8 },
		{ name: 'exclusive group', isMember: false, invite: true, members: 8 },
		{ name: 'dont leave me!', isMember: true, invite: true, members: 9 }
	];
</script>

{#each workingGroups as workingGroup}
	<div class="bg-white dark:bg-darkobject w-full p-6 mb-6">
		{workingGroup.name}
		{workingGroup.members}

		{#if workingGroup.isMember}
			<Button buttonStyle="warning">Leave</Button>
		{:else if workingGroup.invite}
			<Button buttonStyle="primary-light">Ask to Join</Button>
		{:else}
			<Button buttonStyle="primary-light">Join</Button>
		{/if}
	</div>
{/each}
