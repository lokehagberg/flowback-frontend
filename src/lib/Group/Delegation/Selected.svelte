<script lang="ts">
	//Code is not very good in this file, refactoring from scratch needed
	//that incorporates new feature such as delegation pools.
	//Design in Figma should be done first

	import Tag from '../Tag.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Delegate } from '../interface';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { copyObject } from '$lib/Generic/GenericFunctions';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';

	let delegates: Delegate[] = [];
	let oldDelegation: Delegate[] = [];
	let tags: any[] = [];
	let status: number;

	onMount(async () => {
		setDelegators();
		setTagList();
	});

	const saveDelegation = async () => {
		const toSendDelegates = delegates.map(({ pool_id, tags }) => ({
			delegate_pool_id: pool_id,
			tags: tags.map(({ id }) => id)
		}));

		const { res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/delegate/update`,
			toSendDelegates
		);
		
		status = res.status
	};

	const getDelegateRelations = async () => {
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/delegates?limit=100`);
		return json.results;
	};

	const setTagList = async () => {
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/tags?limit=100`);
		tags = json.results.map(({ active, ...args }: any) => args);
		console.log(tags);
	};

	const getDelegationPools = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?limit=100`
		);

		return json.results;
		// delegates = json.results
	};

	const setDelegators = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?limit=100&delegate=true`
		);

		// const delegatePools = await getDelegationPools();
		const delegateRelations = await getDelegateRelations();
		const delegatePools = await getDelegationPools();
		const _delegates: any = [];

		// console.log(delegateRelations[1].delegates[0].user_id, "TAGS")
		for (let i = 0; i < json.results.length; i++) {
			const delegate = json.results[i];

			const delegateRelation = delegateRelations.find(
				(delegateRelation: any) => delegateRelation.delegates[0].group_user_id === delegate.id
			);
			const tags = delegateRelation?.tags;
			const pool_id = delegatePools.find(
				(pool: any) => pool.delegates[0].user_id === delegate.user_id
			).id;
			// const tags = delegateRelations.find(element => )
			if (delegate.delegate)
				_delegates[i] = {
					id: delegate.id,
					pool_id,
					profile_image: delegate.profile_image,
					username: delegate.username || '',
					tags: tags || []
				};
		}

		//If a user is not a delegate it will be empty in _delegates, this clears those empty delegates
		delegates = _delegates.filter((element: any) => Object.keys(element).length !== 0);
		if (oldDelegation.length === 0) oldDelegation = copyObject(delegates);
	};

	//Pops up the "Edit tags for delegate" screen for user with the following id, -1 being no delegate
	let selected = -1;

	const changeDelegation = (delegate: any, tag: { tag_name: string; id: number }) => {
		const delegateOld = delegates.find((delegate) =>
			delegate.tags.find((_tag) => _tag.id === tag.id)
		);

		console.log(delegates);
		if (delegateOld) delegateOld.tags = delegateOld?.tags.filter((_tag: any) => _tag.id !== tag.id);
		if (delegateOld?.id === delegate.id) {
			delegates = delegates;
			return;
		}

		delegate.tags.push(tag);
		delegates = delegates;
	};
</script>

{#if delegates.length !== 0}
	<ul class="w-full">
		{#each delegates as delegate}
			<li class="bg-white p-3 w-full border-b-2 border-gray-200">
				<div class="flex">
					<div class="bg-red-500 w-10 h-10" />
					<a href={`/user?id=${delegate.id}`} class="hover:underline text-black w-64 ml-10"
						>{delegate.username}</a
					>
				</div>
				<div class="flex items-center">
					<div class="flex gap-2 flex-wrap mt-4">
						{#each delegate.tags as tag}
							<Tag tag={tag.tag_name} />
						{/each}
					</div>
					<div
						class:selected={selected === delegate.id}
						class="faPlus ml-auto cursor-pointer"
						on:click={() => (selected === delegate.id ? (selected = -1) : (selected = delegate.id))}
					>
						<Fa icon={faPlus} size="2x" />
					</div>
				</div>
				<div
					class="bg-white p-6 mt-6 shadow rounded border border-gray-200 z-50 right-5"
					class:hidden={selected !== delegate.id}
				>
					<h1 class="text-xl">Edit tags for {delegate.username}</h1>
					<TextInput label="Search" />
					<ul class="mt-6 flex flex-wrap items-center">
						{#each tags as tag}
							<li
								class="w-full md:w-1/2 lg:w-1/3 xl:w-1/4 border border-white border-4"
								on:click={() => changeDelegation(delegate, tag)}
							>
								<Tag
									tag={tag.tag_name}
									Class={`cursor-pointer ${
										delegate.tags.find((_tag) => _tag.id === tag.id) ? 'bg-blue-300' : 'bg-blue-600'
									}`}
								/>
							</li>
						{/each}
					</ul>
				</div>
			</li>
		{/each}
	</ul>
	<StatusMessage bind:status />
	<ButtonPrimary Class="mt-4 mb-2 hover:bg-blue-800" action={saveDelegation}
		>Save Changes</ButtonPrimary
	>
{:else}
	<div>No Delegates selected</div>
{/if}

<style>
	.faPlus {
		transition: transform 400ms cubic-bezier(0.075, 0.82, 0.165, 1);
	}

	.selected {
		transform: rotate(45deg);
	}
</style>
