<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';

	export let creatingGroup: boolean;

	let name = '',
		groupMembers: any[] = [];
</script>

<TextInput autofocus required bind:value={name} label="Chatgroup Name" />

Members
<div>
	{#each groupMembers as member}
		{member.name}
	{/each}
</div>
