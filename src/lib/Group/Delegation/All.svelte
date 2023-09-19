<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { User } from '$lib/User/interfaces';
	import Button from '$lib/Generic/Button.svelte';
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import { _ } from 'svelte-i18n';
	import Loader from '$lib/Generic/Loader.svelte';
	import { delegation as delegationLimit } from '../../Generic/APILimits.json';

	// TODO: fix multiple instances of Delegate interface
	interface Delegate extends User {
		delegate_pool_id: number;
		isInRelation: boolean;
	}

	let delegates: Delegate[] = [],
		delegateRelations: any[] = [],
		userIsDelegate: boolean = false,
		userId: number,
		loading = false;

	export let history: number | null, selectedPage: 'All' | 'Selected' | 'History';

	onMount(async () => {
		userId = (await fetchRequest('GET', 'user')).json.id;
		await getDelegateRelations();
		getDelegatePools();
		getUserInfo();

		// userIsDelegateStore.subscribe((info) => {
		// 	userIsDelegate = info;
		// 	console.log(info, 'INFO');
		// });
	});

	const getUserInfo = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?user_id=${localStorage.getItem('userId')}&delegate=true`
		);
		if (res.ok) userIsDelegate = true;
	};

	const handleCreateDelegationButton = async () => {
		await createDelegationPool();
		getDelegatePools();
	};

	const handleDeleteDelegationButton = async () => {
		await deleteDelegationPool();
		getDelegatePools();
		userIsDelegate = false;
	};

	/*
	 	Makes the currently logged in user into a delegate(pool)
	 */
	const createDelegationPool = async () => {
		loading = true;
		const { res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/delegate/pool/create`
		);

		if (!res.ok) return;

		loading = false;
		userIsDelegate = true;
		// userIsDelegateStore.update((value) => (value = true));
	};

	/*
		Makes the currently logged in user no longer a delegate(pool)
	*/
	const deleteDelegationPool = async () => {
		loading = true;
		const { res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/delegate/pool/delete`
		);
		loading = false;

		if (!res.ok) return;

		userIsDelegate = false;
		// userIsDelegateStore.update((value) => (value = false));
	};

	/*
		Temporary fix to make each delegate pool be associated with one user.
		TODO: Implement delegate pool feature in the front end (Figma design first)
	*/
	const getDelegatePools = async () => {
		loading = true;
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?limit=${delegationLimit}`
		);

		const delegateRelationPoolIds = delegateRelations.map((delegate) => delegate.delegate_pool_id);

		delegates = await Promise.all(
			json.results.map(async (delegatePool: any) => {
				console.log(delegatePool.delegates[0].user_id, 'ID');
				const delegateUserData = await (
					await fetchRequest('GET', `users?id=${delegatePool.delegates[0].user_id}`)
				).json.results[0];

				const isInRelation = delegateRelationPoolIds.includes(delegatePool.id);

				return { ...delegateUserData, delegate_pool_id: delegatePool.id, isInRelation };
			})
		);
		loading = false;
	};

	const getDelegateRelations = async () => {
		loading = true;
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegates?limit=${delegationLimit}`
		);
		loading = false;
		delegateRelations = json.results;
	};

	const createDelegateRelation = async (delegate_pool_id: number) => {
		loading = true;
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/delegate/create`, {
			delegate_pool_id
		});

		loading = false;
		if (res.ok)
			delegates[
				delegates.findIndex((delegate) => delegate.delegate_pool_id === delegate_pool_id)
			].isInRelation = true;
	};

	const deleteDelegateRelation = async (delegate_pool_id: number) => {
		loading = true;
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/delegate/delete`, {
			delegate_pool_id
		});

		loading = false;
		if (res.ok)
			delegates[
				delegates.findIndex((delegate) => delegate.delegate_pool_id === delegate_pool_id)
			].isInRelation = false;
	};
</script>

{#if delegates.length > 0 && loading === false}
	<ul class="w-full">
		{#each delegates as delegate}
			<li
				class="bg-white dark:bg-darkobject dark:text-darkmodeText p-3 w-full border-b-2 border-gray-200 flex justify-between items-center"
			>
				<div
					class="cursor-pointer hover:underline flex items-center"
					on:keydown
					on:click={() => (window.location.href = `/user?id=${delegate.id}`)}
				>
					<img
						src={delegate.profile_image
							? `${import.meta.env.VITE_API}${delegate.profile_image}`
							: DefaultPFP}
						alt="avatar"
						class="w-10 h-10 rounded-full"
					/>
					<span class="ml-4 mr-4">{delegate.username}</span>
				</div>
				<span
					on:keydown
					class="text-gray-500 dark:text-gray-400 cursor-pointer hover:underline"
					on:click={() => {
						history = delegate.delegate_pool_id;
						selectedPage = 'History';
					}}>{$_('See delegate history')}</span
				>
				{#if userId !== delegate.id}
					<div />
					{#if delegate.isInRelation}
						<Button
							Class={'bg-red-500'}
							action={() => deleteDelegateRelation(delegate.delegate_pool_id)}
							>{$_('Remove as delegate')}</Button
						>
					{:else}
						<Button action={() => createDelegateRelation(delegate.delegate_pool_id)}
							>{$_('Add as delegate')}</Button
						>
					{/if}
				{/if}
			</li>
		{/each}
	</ul>
{:else if delegates.length > 0 && loading === false}
	<div>{$_('No delegates in group')}</div>
{:else if loading === true}
	<Loader bind:loading />
{/if}

{#if userIsDelegate}
	<Button Class="mt-3 bg-red-500" action={handleDeleteDelegationButton}
		>{$_('Stop being delegate')}</Button
	>
{:else}
	<Button Class="mt-3 bg-red-500" action={handleCreateDelegationButton}
		>{$_('Become delegate')}</Button
	>
{/if}
