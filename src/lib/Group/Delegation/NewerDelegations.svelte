<!-- Currently only supports one group flowback -->
<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { Group, Tag } from '../interface';
	import type { Delegate, DelegateRelation } from './interfaces';
	import type { poppup } from '$lib/Generic/Poppup';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import Fa from 'svelte-fa';
	import { faChevronDown, faChevronUp } from '@fortawesome/free-solid-svg-icons';

	export let group: Group,
		delegates: Delegate[] = [];

	let tags: Tag[] = [],
		userIsDelegate = false,
		expandedSection: any = null,
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

	const getDelegateRelations = async () => {
		const { json } = await fetchRequest('GET', `group/${group.id}/delegates?limit=1000`);

		//Determines whether to show the "remove as delegate" or "add as delegate" buttons, depening on if user already has delegated or not earlier.
		json.results.forEach((relation: any) => {
			delegates.map((delegate) => {
				if (delegate.pool_id === relation.delegate_pool_id) delegate.isInRelation = true;
				return delegate;
			});
		});
		// delegateRelations = json.results;
		delegateRelations = json.results;
	};

	const changeDelegation = async (delegate: Delegate, tag: Tag) => {
		delegationTagsStructure.forEach((relation, i) => {
			const previousTagRelationIndex = relation.tags.findIndex((_tag) => _tag === tag.id);

			if (previousTagRelationIndex !== -1) relation.tags.splice(previousTagRelationIndex);
			else if (relation.delegate_pool_id === delegate.pool_id) relation.tags.push(tag.id);
		});

		delegateRelations.forEach((relation, i) => {
			const previousTagRelationIndex = relation.tags.findIndex((_tag) => _tag.id === tag.id);

			if (previousTagRelationIndex !== -1) relation.tags.splice(previousTagRelationIndex);
			else if (relation.delegate_pool_id === delegate.pool_id) relation.tags.push(tag);
		});

		await createDelegateRelation(delegate.pool_id);
		saveDelegation();
	};

	const createDelegateRelation = async (delegate_pool_id: number) => {
		const { res } = await fetchRequest('POST', `group/${group.id}/delegate/create`, {
			delegate_pool_id
		});

		if (!res.ok) return;

		delegates[
			delegates.findIndex((delegate) => delegate.pool_id === delegate_pool_id)
		].isInRelation = true;
	};

	const saveDelegation = async () => {
		const toSendDelegates = delegateRelations.map(({ tags, delegate_pool_id }) => ({
			delegate_pool_id,
			tags: tags.map(({ id }) => id)
		}));

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
	};

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
	{#each tags as tag, index}
		<div class="section">
			<button
				class="transition-all flex text-primary dark:text-secondary justify-between w-full section-title"
				on:click={() => toggleSection(index)}
			>
				<span class="break-all text-left">{tag.name}</span>

				<!-- Always use chevron-down and rotate when expanded -->
				<div class="chevron {expandedSection === index ? 'expanded' : ''}">
					<Fa icon={faChevronDown} />
				</div>
			</button>

			<!-- {#if expandedSection === index}
				 flip={expandedSection !== index}
					<Fa icon={faChevronUp} />
				{:else}
					<Fa icon={faChevronDown} />
				{/if} -->
			{#if expandedSection === index}
				<!-- {#if section.voters.length > 0} -->
				<div class="voter-list">
					{#each delegates as delegate}
						<div class="voter-item">
							<ProfilePicture
								displayName
								username={delegate.user.username}
								userId={delegate.user.id}
								profilePicture={delegate.user.profile_image}
							/>
							<!-- {delegate.user.username} -->
							<!-- {delegate.delegates[0]} -->
							<!-- <span>{delegate.delegates[0]}</span> -->
							<span>
								<!-- {delegate.percentage}% -->
								<input
									disabled={delegate.user.id.toString() === localStorage.getItem('userId')}
									on:input={() => changeDelegation(delegate, tag)}
									type="radio"
									name={tag.name}
									checked={delegationTagsStructure
										.find((relation) => relation.delegate_pool_id === delegate.pool_id)
										?.tags.find((_tag) => _tag === tag.id) !== undefined}
								/>
							</span>
						</div>
					{/each}
				</div>
			{:else}
				<!-- <div class="voter-list">Inga rekommenderade väljare.</div> -->
			{/if}
			<!-- {/if} -->
		</div>
	{/each}
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
