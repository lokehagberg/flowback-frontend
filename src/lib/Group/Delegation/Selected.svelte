<script lang="ts">
	//Code is not very good in this file, refactoring from scratch needed
	//that incorporates new feature such as delegation pools.
	//Design in Figma should be done first

	import Tag from '../Tag.svelte';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Delegate } from '../interface';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import Button from '$lib/Generic/Button.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { _ } from 'svelte-i18n';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { delegation as delegationLimit } from '../../Generic/APILimits.json';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';

	let delegates: Delegate[] = [],
		tags: any[] = [],
		poppup: poppup,
		loading = false;

	onMount(async () => {
		setDelegators();
		setTagList();
	});

	const saveDelegation = async () => {
		loading = true;
		const toSendDelegates = delegates.map(({ pool_id, tags }) => ({
			delegate_pool_id: pool_id,
			tags: tags.map(({ id }) => id)
		}));

		const { res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/delegate/update`,
			toSendDelegates
		);

		if (res.ok) poppup = { message: 'Success', success: true };
		loading = false;
	};

	const getDelegateRelations = async () => {
		loading = true;
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegates?limit=${delegationLimit}`
		);
		loading = false;
		if (!res.ok) {
			poppup = { message: 'Could not get delegates', success: false };
			return [];
		}

		return json.results;
	};

	const setTagList = async () => {
		loading = true;
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/tags?limit=${delegationLimit}`
		);
		tags = json.results.map(({ active, ...args }: any) => args);
		loading = false;
	};

	const getDelegatesUserInfo = async () => {
		loading = true;
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?limit=${delegationLimit}&delegate=true`
		);
		loading = false;
		return json.results;
	};

	const getDelegationPools = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?limit=${delegationLimit}`
		);

		return json.results;
	};

	const setDelegators = async () => {
		const delegatesUserInfo: any[] = await getDelegatesUserInfo();
		const delegateRelations: any[] = await getDelegateRelations();

		delegateRelations.forEach((relation) => {
			const info = delegatesUserInfo.find((user) => user.user.id === relation.delegates[0].user_id);
			console.log(delegatesUserInfo, delegateRelations, info, 'LOG');

			const delegate: Delegate = {
				pool_id: relation.delegate_pool_id,
				id: relation.id,
				profile_image: info.profile_image,
				username: info.user.username,
				tags: relation.tags
			};

			delegates.push(delegate);
		});

		delegates = delegates;
	};

	//Pops up the "Edit tags for delegate" screen for user with the following id, -1 being no delegate
	let selected = -1;

	const changeDelegation = (delegate: any, tag: { tag_name: string; id: number }) => {
		const delegateOld = delegates.find((delegate) =>
			delegate.tags.find((_tag) => _tag.id === tag.id)
		);

		if (delegateOld) delegateOld.tags = delegateOld?.tags.filter((_tag: any) => _tag.id !== tag.id);
		if (delegateOld?.id === delegate.id) {
			delegates = delegates;
			return;
		}

		delegate.tags.push(tag);
		delegates = delegates;
	};
</script>

{#if delegates.length !== 0 && loading === false}
	<ul class="w-full">
		{#each delegates as delegate}
			<li
				class="bg-white dark:bg-darkobject dark:text-darkmodeText p-3 w-full border-b-2 border-gray-200"
			>
				<div class="flex">
					<ProfilePicture user={delegate} displayName />
				</div>
				<div class="flex items-center">
					<div class="flex gap-2 flex-wrap mt-4">
						{#each delegate.tags as tag}
							<Tag {tag} />
						{/each}
					</div>
					<!-- svelte-ignore a11y-click-events-have-key-events -->
					<!-- svelte-ignore a11y-no-static-element-interactions -->
					<div
						class:selected={selected === delegate.id}
						class="faPlus ml-auto cursor-pointer"
						on:click={() => (selected === delegate.id ? (selected = -1) : (selected = delegate.id))}
					>
						<Fa icon={faPlus} size="2x" />
					</div>
				</div>
				<div
					class="bg-white dark:bg-darkbackground p-6 mt-6 shadow rounded border border-gray-200 z-50 right-5"
					class:hidden={selected !== delegate.id}
				>
					<h1 class="text-xl">{$_('Edit tags for')} {delegate.username}</h1>
					<!-- <TextInput label="Search" /> -->
					<ul class="mt-6 flex flex-wrap items-center">
						<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
						{#each tags as tag}
							<!-- svelte-ignore a11y-click-events-have-key-events -->
							<li
								class="w-full md:w-1/2 lg:w-1/3 xl:w-1/4 border-white border-4"
								on:click={() => changeDelegation(delegate, tag)}
							>
								<Tag
									{tag}
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
	
	<Button Class="mt-4 mb-2 bg-blue-600 hover:bg-blue-800" action={saveDelegation}
		>{$_('Save changes')}</Button
	>
{:else if loading === false}
	<div>{$_('No delegates selected')}</div>
{:else if loading === true}
	<Loader bind:loading />
{/if}

<Poppup bind:poppup />

<style>
	.faPlus {
		transition: transform 400ms cubic-bezier(0.075, 0.82, 0.165, 1);
	}

	.selected {
		transform: rotate(45deg);
	}
</style>

