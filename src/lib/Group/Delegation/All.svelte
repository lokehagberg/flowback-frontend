<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { User } from '$lib/User/interfaces';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { userIsDelegateStore } from '$lib/Group/interface';
	import DefaultPFP from '$lib/assets/Default_pfp.png';

	let delegates: User[] = [];
	let delegateRelations: any[] = [];
	let userIsDelegate: boolean;

	const createDelegationPool = async () => {
		const { res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/delegate/pool/create`
		);

		if (!res.ok) return;

		getDelegatePools();
		userIsDelegateStore.update((value) => (value = true));
	};

	const deleteDelegationPool = async () => {
		const { res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/delegate/pool/delete`
		);

		if (!res.ok) return;

		getDelegatePools();
		userIsDelegateStore.update((value) => (value = false));
	};

	const getDelegatePools = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?limit=100`
		);

		/*
			Temporary fix to make each delegate pool be associated with one user.
			TODO: Implement delegate pool feature in the front end (Figma design first)
		*/
		delegates = await Promise.all(
			json.results.map(async (delegatePool: any) => {
				return await (
					await fetchRequest('GET', `users?id=${delegatePool.delegates[0].user_id}`)
				).json.results[0];
			})
		);
	};

	const getDelegateRelations = async () => {
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/delegates?limit=100`);
		delegateRelations = json.results;
	};

	onMount(() => {
		getDelegatePools();
		getDelegateRelations();

		userIsDelegateStore.subscribe((info) => {
			userIsDelegate = info;
		});
	});
</script>

<ul class="w-full">
	{#each delegates as delegate}
		<li class="bg-white p-3 w-full border-b-2 border-gray-200 flex justify-between items-center">
			<div
				class="cursor-pointer hover:underline flex items-center"
				on:click={() => (window.location.href = `/user?id=${delegate.id}`)}
			>
				<img src={DefaultPFP} alt="avatar" class="w-10 h-10" />
				<span class="text-black ml-4 mr-4">{delegate.username}</span>
			</div>
			<ButtonPrimary>Add as Delegate</ButtonPrimary>
		</li>
	{/each}
</ul>

{#if userIsDelegate}
	<ButtonPrimary Class="mt-3 bg-red-500" action={deleteDelegationPool}
		>Stop being Delegate</ButtonPrimary
	>
{:else}
	<ButtonPrimary Class="mt-3" action={createDelegationPool}>Become Delegate</ButtonPrimary>
{/if}
