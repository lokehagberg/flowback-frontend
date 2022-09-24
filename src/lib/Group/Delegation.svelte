<script lang="ts">
	import Tag from './Tag.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Delegate, DelegatePools } from './interface';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';

	let delegates: Delegate[] = [];
	let tags: any[] = [];

	onMount(async () => {
		// createDelegationPool()
		getDelegationPools();
		getDelegators();
		getTagList();
		getDelegateRelations();

		// const { json } = await fetchRequest(
		// 	'POST',
		// 	`group/${$page.params.groupId}/delegates/create`,
		// 	{}
		// );
	});

	const getDelegateRelations = async () => {
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/delegates?limit=100`);
		return json.results
	};

	const createDelegateRelations = async () => {
		const { json } = await fetchRequest('POST', `group/${$page.params.groupId}/delegate/create`, {
			delegate_pool_id: 7,
			tags: [1, 2]
		});
	};

	const editDelegateRelations = async () => {
		const { json } = await fetchRequest('POST', `group/${$page.params.groupId}/delegate/update`, {
			delegate_pool_id: 7,
			tags: [1,2]
		});
	};

	const getTagList = async () => {
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/tags?limit=100`);

		tags = json.results;
	};

	const getDelegationPools = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?limit=100`
		);

		return json.results;
		// delegates = json.results
	};

	const getDelegators = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?limit=100&delegate=true`
		);

		const delegatePools = await getDelegationPools();
		const delegateRelations = await getDelegateRelations();
		const _delegates: any = [];

		for (let i = 0; i < json.results.length; i++) {
			const delegate = json.results[i];

			const tags = delegateRelations.find((delegateRelation:any) => delegateRelation.delegates[0].user_id === delegate.id)?.tags
			console.log(tags, "TAGS")
			// const tags = delegateRelations.find(element => )

			if (delegate.delegate)
				_delegates[i] = {
					id: delegate.id,
					profile_image: delegate.profile_image,
					username: delegate.username || '',
					tags:tags || []
				};
		}
		delegates = _delegates.filter((element: any) => Object.keys(element).length !== 0);
	};

	const createDelegationPool = async () => {
		fetchRequest('POST', `group/${$page.params.groupId}/delegate/pool/create`, {});
	};

	const deleteDelegationPool = async () => {
		fetchRequest('POST', `group/${$page.params.groupId}/delegate/pool/delete`, {});
	};

	//Pops up the "Edit tags for delegate" screen for user with the following id, -1 being no delegate
	let selected = -1;

	const changeDelegation = (delegate: any, tag: {tag_name:string, id:number}) => {
		const delegateOld = delegates.find((delegate) => delegate.tags.includes(tag));

		if (delegateOld) delegateOld.tags = delegateOld?.tags.filter((_tag: any) => _tag !== tag);
		if (delegateOld?.id === delegate.id) {
			delegates = delegates;
			return;
		}

		delegate.tags.push(tag);
		delegates = delegates;
	};
</script>

<div class="flex flex-col items-center gap-2 mb-24 bg-white rounded shadow p-4">
	<ButtonPrimary action={editDelegateRelations}>Save Changes</ButtonPrimary>
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
							on:click={() =>
								selected === delegate.id ? (selected = -1) : (selected = delegate.id)}
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
									on:click={() => changeDelegation(delegate, tag.tag_name)}
								>
									<Tag
										tag={tag.tag_name}
										className={`cursor-pointer ${
											delegate.tags.includes(tag.tag_name) ? 'bg-blue-300' : 'bg-blue-600'
										}`}
									/>
								</li>
							{/each}
						</ul>
					</div>
				</li>
			{/each}
		</ul>
	{/if}
</div>

<!-- Reminder: Delegate by searching for their ID in the user list and then use that ID to search for it in the delegate pool list -->
<style>
	.faPlus {
		transition: transform 400ms cubic-bezier(0.075, 0.82, 0.165, 1);
	}

	.selected {
		transform: rotate(45deg);
	}
</style>
