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
		expandedSection: any = null,
		previousExpandedSection: any = null,
		delegateRelations: DelegateRelation[] = [],
		poppup: poppup,
		delegationTagsStructure: { delegate_pool_id: number; tags: number[] }[] = [];

	const setupDelegationTagStructure = () => {
		delegationTagsStructure = delegateRelations.map(({ tags, delegate_pool_id }) => ({
			delegate_pool_id,
			tags: tags.map(({ id }) => id)
		}));
	};

	const getGroupTags = async () => {
		const { res, json } = await fetchRequest('GET', `group/${group.id}/tags?limit=1000`);

		tags = json.results;

		if (!res.ok) return;
	};

	/*
		Temporary fix to make each delegate pool be associated with one user.
		TODO: Implement delegate pool feature in the front end (Figma design first)
	*/
	const getDelegatePools = async () => {
		const { json, res } = await fetchRequest('GET', `group/${group.id}/delegate/pools?limit=1000`);
		if (!res.ok) return;

		delegates = json.results.map((delegatePool: any) => {
			return { ...delegatePool.delegates[0].group_user, pool_id: delegatePool.id };
		});
	};

	const toggleSection = (index: any) => {
		expandedSection = expandedSection === index ? null : index;
	};

	const reinitializeRadioState = async () => {
		await tick(); // Ensure DOM is updated
		delegates = [...delegates]; // Trigger reactivity
	};

	const getDelegateRelations = async () => {
		const { json, res } = await fetchRequest('GET', `group/${group.id}/delegates?limit=1000`);

		// Determines whether to show the "remove as delegate" or "add as delegate" buttons, depending on if user already has delegated or not earlier.
		json.results.forEach((relation: any) => {
			delegates.map((delegate) => {
				if (delegate.pool_id === relation.delegate_pool_id) delegate.isInRelation = true;
				return delegate;
			});
		});
		delegateRelations = json.results;
		if (res.ok) {
			setupDelegationTagStructure();
		}
	};

	const changeDelegation = async (delegate: Delegate, tag: Tag) => {
		// Check if a relation exists for this delegate; if not, create one
		let relation = delegateRelations.find((r) => r.delegate_pool_id === delegate.pool_id);
		if (!relation) {
			relation = { delegate_pool_id: delegate.pool_id, tags: [] };
			delegateRelations = [...delegateRelations, relation];
		}

		// Update delegationTagsStructure
		let tagStructure = delegationTagsStructure.find(
			(r) => r.delegate_pool_id === delegate.pool_id
		);
		if (!tagStructure) {
			tagStructure = { delegate_pool_id: delegate.pool_id, tags: [] };
			delegationTagsStructure = [...delegationTagsStructure, tagStructure];
		}

		// Remove tag from other delegates' relations
		delegationTagsStructure.forEach((r) => {
			const tagIndex = r.tags.findIndex((_tag) => _tag === tag.id);
			if (tagIndex !== -1) r.tags.splice(tagIndex, 1);
		});
		delegateRelations.forEach((r) => {
			const tagIndex = r.tags.findIndex((_tag) => _tag.id === tag.id);
			if (tagIndex !== -1) r.tags.splice(tagIndex, 1);
		});

		// Add tag to the selected delegate's relation
		if (!tagStructure.tags.includes(tag.id)) {
			tagStructure.tags.push(tag.id);
		}
		if (!relation.tags.some((t) => t.id === tag.id)) {
			relation.tags.push({ ...tag, active: true, tag_name: tag.name });
		}

		// Update state
		delegationTagsStructure = [...delegationTagsStructure];
		delegateRelations = [...delegateRelations];

		await createDelegateRelation(delegate.pool_id);
		await saveDelegation();
	};

	const createDelegateRelation = async (delegate_pool_id: number) => {
		const { json, res } = await fetchRequest('POST', `group/${group.id}/delegate/create`, {
			delegate_pool_id
		});
		console.log("createDelegateRelation", res, res.ok);
		if (!res.ok) {
			poppup = { message: 'Failed to create delegation', success: false };
			return;
		}

		delegates[
			delegates.findIndex((d) => d.pool_id === delegate_pool_id)
		].isInRelation = true;

		// Ensure a relation exists in delegateRelations
		if (!delegateRelations.some((r) => r.delegate_pool_id === delegate_pool_id)) {
			delegateRelations = [
				...delegateRelations,
				{ delegate_pool_id, tags: [] }
			];
			setupDelegationTagStructure();
		}

		// Trigger UI update
		reinitializeRadioState();
	};

	const updateDelegationTagsStructure = () => setupDelegationTagStructure();

	const saveDelegation = async () => {
		const toSendDelegates = delegateRelations.map(({ tags, delegate_pool_id }) => ({
			delegate_pool_id,
			tags: tags.map(({ id }) => id)
		}));
		console.log("saveDelegation delegateRelations", delegateRelations);
		console.log("saveDelegation toSendDelegates", toSendDelegates);

		const { res } = await fetchRequest(
			'POST',
			`group/${group.id}/delegate/update`,
			toSendDelegates
		);

		if (!res.ok) {
			poppup = { message: 'Failed to save new delegation', success: false };
			return;
		}
		poppup = { message: 'Successfully saved delegation', success: true };

		// Refresh relations to ensure consistency with backend
		await getDelegateRelations();
	};

	const clearChoice = async (tag: Tag) => {
		delegationTagsStructure.forEach((delegate) => {
			delegate.tags = delegate.tags?.filter((_tag) => {
				return _tag !== tag.id;
			});
		});

		delegateRelations.forEach((delegate) => {
			delegate.tags = delegate.tags?.filter((_tag) => {
				return _tag.id !== tag.id;
			});
		});

		delegationTagsStructure = [...delegationTagsStructure];
		delegateRelations = [...delegateRelations];
		await saveDelegation();
	};

	$: if (expandedSection !== previousExpandedSection) {
		reinitializeRadioState();
		previousExpandedSection = expandedSection;
	}

	const initialSetup = async () => {
		getGroupTags();
		getDelegatePools();
		await getDelegateRelations();
		setupDelegationTagStructure();
	};

	onMount(async () => {
		initialSetup();
	});

	$: if (group) {
		initialSetup();
	}
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

					<!-- Always use chevron-down and rotate when expanded -->
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
								<!-- {delegate.user.username}
								{delegate.delegates[0]} -->
								<span>
									<input
										disabled={delegate.user.id.toString() === localStorage.getItem('userId')}
										on:input={() => {
											changeDelegation(delegate, tag);
											setTimeout(() => {
												updateDelegationTagsStructure();
												reinitializeRadioState();
											}, 1000);
										}}
										type="radio"
										key={`${tag.id}-${delegate.pool_id}`}
										name={tag.name}
										checked={delegationTagsStructure
											.find((relation) => relation.delegate_pool_id === delegate.pool_id)
											?.tags.find((_tag) => _tag === tag.id) !== undefined}
									/>
								</span>
							</div>
						{/each}
					</div>
					<button class="text-red-700 hover:underline" on:click={() => clearChoice(tag)}
						>{$_('Clear Choice')}</button
					>
				{:else}
					<!-- <div class="voter-list">Inga rekommenderade väljare.</div> -->
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