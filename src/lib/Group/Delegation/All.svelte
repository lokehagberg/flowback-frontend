<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { User } from '$lib/User/interfaces';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';

	let delegates: User[] = [];

	const createDelegationPool = async () => {
		fetchRequest('POST', `group/${$page.params.groupId}/delegate/pool/create`, {});
	};

	const deleteDelegationPool = async () => {
		fetchRequest('POST', `group/${$page.params.groupId}/delegate/pool/delete`, {});
	};

	const getDelegatePools = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?limit=100`,
			{}
		);
		console.log(json.results, "RESULTS")

		delegates = await Promise.all(
			json.results.map(async (delegatePool: any) => {
				console.log(await (
					await fetchRequest('GET', `user`, { id: delegatePool.delegates[0].user_id })
				).json)
				return await (
					await fetchRequest('GET', `user`, { id: delegatePool.delegates[0].user_id })
				).json;
			})
		);
	};

	onMount(() => {
		getDelegatePools();
	});
</script>

<ul class="w-full">
	{#each delegates as delegate}
		<li class="bg-white p-3 w-full border-b-2 border-gray-200 flex">
			<div class="flex">
				<div class="bg-red-500 w-10 h-10" />
				<a href={`/user?id=${delegate.id}`} class="hover:underline text-black w-64 ml-10"
					>{delegate.username}</a
				>
			</div>
			<ButtonPrimary>Add as Delegate</ButtonPrimary> 
		</li>
	{/each}
</ul>
<ButtonPrimary Class="mt-3">Become Delegate</ButtonPrimary>
