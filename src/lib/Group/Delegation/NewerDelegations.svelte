<!-- Currently only supports one group flowback -->
<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { Group, Tag } from '../interface';
	import type { Delegate, DelegateRelation } from './interfaces';

	export let group: Group,
		delegates: Delegate[] = [];

	let tags: Tag[] = [],
		userIsDelegate = false,
		expandedSection: any = null,
		delegateRelations: DelegateRelation[] = [];

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

	onMount(async () => {
		getGroupTags();
		getDelegatePools();
		getDelegateRelations();
	});
</script>

<div>
	{#each tags as tag, index}
		<div class="section">
			<button
				class=" flex justify-between w-full section-title"
				on:click={() => toggleSection(index)}
			>
				<span class="break-all text-left">{tag.name}</span>
				<span>{expandedSection === index ? '▲' : '▼'}</span>
			</button>
			{#if expandedSection === index}
				<!-- {#if section.voters.length > 0} -->
				<div class="voter-list">
					{#each delegates as delegate}
						<div class="voter-item">
							{delegate.user.username}
							<!-- {delegate.delegates[0]} -->
							<!-- <span>{delegate.delegates[0]}</span> -->
							<span>
								<!-- {delegate.percentage}% -->
								<input
									type="radio"
									name={tag.name}
									checked={delegateRelations.find(
										(relation) =>
											relation.delegate_pool_id === delegate.pool_id &&
											relation.tags.find((tag) => tag?.id === tag.id)
									) !== undefined}
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
</style>
