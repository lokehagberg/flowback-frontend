<script lang="ts">
	import Loader from '$lib/Generic/Loader.svelte';
	import type { Tag } from '../interface';
	import { page } from '$app/stores';
	import { getTags } from '../functions';
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa';
	import { faAngleDown, faAngleRight } from '@fortawesome/free-solid-svg-icons';

	let loading = false,
		tags: Tag[] = [];

	const getTagsLocal = async () => {
		loading = true;
		tags = await getTags($page.params.groupId);
		// if (!tags) poppup = { message: 'Could not get poppups', success: false };
		loading = false;
	};

	onMount(() => {
		getTagsLocal();
	});
</script>

<Loader bind:loading>
	<div class="delegation-grid gap-4">
		<div class="bg-white p-4">
			{#each tags as tag}
				<div class="text-primary font-bold flex items-center justify-between cursor-pointer">
					{tag.name}
					<Fa icon={faAngleRight} />
				</div>
			{/each}
		</div>
		<div class="bg-white p-4">hi</div>
	</div>
</Loader>

<style>
	.delegation-grid {
		display: grid;
		grid-template-columns: 0.8fr 1fr;
	}
</style>
