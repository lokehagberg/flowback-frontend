<script lang="ts">
	import Loader from '$lib/Generic/Loader.svelte';
	import type { Tag } from '../interface';
	import { page } from '$app/stores';
	import { getTags } from '../functions';
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa';
	import { faAngleDown, faAngleRight } from '@fortawesome/free-solid-svg-icons';
	import { fetchRequest } from '$lib/FetchRequest';
	import { delegation as delegationLimit } from '../../Generic/APILimits.json';
	import type { Delegate } from './interfaces';
	import Select from '$lib/Generic/Select.svelte';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';

	let loading = false,
		tags: Tag[] = [],
		delegates: Delegate[] = [];

	const getTagsLocal = async () => {
		loading = true;
		tags = await getTags($page.params.groupId);
		// if (!tags) poppup = { message: 'Could not get poppups', success: false };
		loading = false;
	};

	const getDelegatePools = async () => {
		loading = true;
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?limit=${delegationLimit}`
		);

		if (!res.ok) return;

		delegates = json.results.map((delegatePool: any) => {
			return { ...delegatePool.delegates[0].group_user, pool_id: delegatePool.id };
		});

		loading = false;
	};

	onMount(() => {
		getTagsLocal();
		getDelegatePools();
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
		<div class="bg-white p-4">
            <RadioButtons2 name="delegation-radio" values={delegates.map(delegate => delegate.id)} labels={delegates.map(delegate => delegate.user.username)}/>
		</div>
	</div>
</Loader>

<style>
	.delegation-grid {
		display: grid;
		grid-template-columns: 0.8fr 1fr;
	}
</style>
