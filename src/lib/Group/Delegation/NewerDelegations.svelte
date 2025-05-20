<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { Group, Tag } from '../interface';
	import type { Delegate, DelegateRelation } from './interfaces';
	import type { poppup } from '$lib/Generic/Poppup';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import Fa from 'svelte-fa';
	import { tick } from 'svelte';
	import { faChevronDown } from '@fortawesome/free-solid-svg-icons';
	import { _ } from 'svelte-i18n';

	export let group: Group,
		delegates: Delegate[] = [];

	let tags: Tag[] = [],
		expandedSection: number | null = null,
		previousExpandedSection: number | null = null,
		delegateRelations: DelegateRelation[] = [],
		poppup: poppup,
		delegationTagsStructure: { delegate_pool_id: number; tags: number[] }[] = [];

	// Lifecycle hooks
	onMount(async () => {
		await initialSetup();
	});

	// Reactive statements
	$: if (group) {
		initialSetup();
	}

	$: if (expandedSection !== previousExpandedSection) {
		reinitializeRadioState();
		previousExpandedSection = expandedSection;
	}

	// Initialization
	const initialSetup = async () => {
		try {
			await Promise.all([getGroupTags(), getDelegatePools(), getDelegateRelations()]);
			setupDelegationTagStructure();
		} catch (error) {
			console.error('Error during initial setup:', error);
		}
	};

	// Fetching data
	const getGroupTags = async () => {
		try {
			const { res, json } = await fetchRequest('GET', `group/${group.id}/tags?limit=1000`);
			if (res.ok) tags = json.results;
		} catch (error) {
			console.error('Failed to fetch group tags:', error);
		}
	};

	const getDelegatePools = async () => {
		try {
			const { res, json } = await fetchRequest(
				'GET',
				`group/${group.id}/delegate/pools?limit=1000`
			);
			if (res.ok) {
				delegates = json.results.map((pool: any) => ({
					...pool.delegates[0].group_user,
					pool_id: pool.id
				}));
			}
		} catch (error) {
			console.error('Failed to fetch delegate pools:', error);
		}
	};

	const getDelegateRelations = async () => {
		try {
			const { res, json } = await fetchRequest('GET', `group/${group.id}/delegates?limit=1000`);
			if (res.ok) {
				delegateRelations = json.results;
				markDelegatesInRelation();
				setupDelegationTagStructure();
			}
		} catch (error) {
			console.error('Failed to fetch delegate relations:', error);
		}
	};

	// Utility functions
	const setupDelegationTagStructure = () => {
		delegationTagsStructure = delegateRelations.map(({ tags, delegate_pool_id }) => ({
			delegate_pool_id,
			tags: tags.map(({ id }) => id)
		}));
	};

	const markDelegatesInRelation = () => {
		delegateRelations.forEach((relation) => {
			delegates.forEach((delegate) => {
				if (delegate.pool_id === relation.delegate_pool_id) {
					delegate.isInRelation = true;
				}
			});
		});
	};

	const toggleSection = (index: number) => {
		expandedSection = expandedSection === index ? null : index;
	};

	const reinitializeRadioState = async () => {
		await tick();
		delegates = [...delegates];
	};

	// Delegation management
	const changeDelegation = async (delegate: Delegate, tag: Tag) => {
		try {
			let relation = delegateRelations.find((r) => r.delegate_pool_id === delegate.pool_id);
			if (!relation) {
				relation = { delegate_pool_id: delegate.pool_id, tags: [] };
				delegateRelations = [...delegateRelations, relation];
			}

			let tagStructure = delegationTagsStructure.find(
				(r) => r.delegate_pool_id === delegate.pool_id
			);
			if (!tagStructure) {
				tagStructure = { delegate_pool_id: delegate.pool_id, tags: [] };
				delegationTagsStructure = [...delegationTagsStructure, tagStructure];
			}

			removeTagFromOtherDelegates(tag);
			addTagToDelegate(tag, relation, tagStructure);

			await createDelegateRelation(delegate.pool_id);
			await saveDelegation();
		} catch (error) {
			console.error('Failed to change delegation:', error);
		}
	};

	const removeTagFromOtherDelegates = (tag: Tag) => {
		delegationTagsStructure.forEach((r) => {
			r.tags = r.tags.filter((_tag) => _tag !== tag.id);
		});
		delegateRelations.forEach((r) => {
			r.tags = r.tags.filter((_tag) => _tag.id !== tag.id);
		});
	};

	const addTagToDelegate = (tag: Tag, relation: DelegateRelation, tagStructure: any) => {
		if (!tagStructure.tags.includes(tag.id)) tagStructure.tags.push(tag.id);
		if (!relation.tags.some((t) => t.id === tag.id)) {
			relation.tags.push({ ...tag, active: true, tag_name: tag.name });
		}
	};

	const createDelegateRelation = async (delegate_pool_id: number) => {
		const { res } = await fetchRequest('POST', `group/${group.id}/delegate/create`, {
			delegate_pool_id
		});
		if (!res.ok) return;

		const delegate = delegates.find((d) => d.pool_id === delegate_pool_id);
		if (delegate) delegate.isInRelation = true;
		setupDelegationTagStructure();
		reinitializeRadioState();
	};

	const saveDelegation = async () => {
		try {
			const toSendDelegates = delegateRelations.map(({ tags, delegate_pool_id }) => ({
				delegate_pool_id,
				tags: tags.map(({ id }) => id)
			}));

			const { res } = await fetchRequest(
				'POST',
				`group/${group.id}/delegate/update`,
				toSendDelegates
			);
			if (res.ok) {
				poppup = { message: 'Successfully saved delegation', success: true };
				await getDelegateRelations();
			} else {
				poppup = { message: 'Failed to save new delegation', success: false };
			}
		} catch (error) {
			console.error('Failed to save delegation:', error);
		}
	};

	const clearChoice = async (tag: Tag) => {
		try {
			removeTagFromOtherDelegates(tag);
			await saveDelegation();
		} catch (error) {
			console.error('Failed to clear choice:', error);
		}
	};
</script>

<div>
	{#if delegates.length > 0}
		{#each tags as tag, index}
			<div class="section">
				<button
					type="button"
					class="transition-all flex text-primary dark:text-secondary justify-between w-full section-title"
					on:click={() => toggleSection(index)}
				>
					<span class="break-all text-left">{tag.name}</span>
					<div class="chevron {expandedSection === index ? 'expanded' : ''}">
						<Fa icon={faChevronDown} />
					</div>
				</button>

				{#if expandedSection === index}
					<div class="voter-list">
						{#each delegates as delegate}
							<div class="voter-item">
								<ProfilePicture
									key={delegate.user.id}
									displayName
									username={delegate.user.username}
									userId={delegate.user.id}
									profilePicture={delegate.user.profile_image}
								/>
								<span>
									<input
										disabled={delegate.user.id.toString() === localStorage.getItem('userId')}
										on:input={() => changeDelegation(delegate, tag)}
										type="radio"
										key={`${tag.id}-${delegate.pool_id}`}
										name={tag.name}
										checked={delegationTagsStructure
											.find((relation) => relation.delegate_pool_id === delegate.pool_id)
											?.tags.includes(tag.id)}
									/>
								</span>
							</div>
						{/each}
					</div>
					<button class="text-red-700 hover:underline" on:click={() => clearChoice(tag)}>
						{$_('Clear Choice')}
					</button>
				{/if}
			</div>
		{/each}
	{:else}
		<span>{$_('There are currently no delegates for this group')}</span>
	{/if}
</div>

<Poppup bind:poppup />

<style>
	.section {
		margin-bottom: 1rem;
		border-bottom: 1px solid #ccc;
	}
	.section-title {
		cursor: pointer;
		font-size: 1.2rem;
		padding: 0.5rem;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}
	.voter-list {
		padding-left: 1rem;
	}
	.voter-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0.5rem;
	}
	.voter-item input[type='radio'] {
		margin-left: 0.5rem;
	}

	.chevron {
		transition: transform 0.4s cubic-bezier(0.77, 0, 0.175, 1);
	}

	.expanded {
		transform: rotate(180deg);
	}
</style>
