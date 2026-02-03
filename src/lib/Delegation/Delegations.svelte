<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { Group, Tag } from '$lib/Group/interface';
	import type { Delegate, DelegateRelation } from './interfaces';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import Fa from 'svelte-fa';
	import { faChevronDown } from '@fortawesome/free-solid-svg-icons';
	import { _ } from 'svelte-i18n';
	import { userStore } from '$lib/User/interfaces';
	import Loader from '$lib/Generic/Loader.svelte';

	export let group: Group,
		delegates: Delegate[] = [];

	let tags: Tag[] = [],
		expandedSection: any = null,
		delegateRelations: DelegateRelation[] = [],
		loading = false;

	onMount(async () => {
		groupDelegationSetup();
	});

	$: if (group) {
		groupDelegationSetup();
	}

	const groupDelegationSetup = async () => {
		loading = true;
		await getGroupTags();
		await getDelegates();
		await getDelegateRelations();
		loading = false;
	};

	const updateDelgation = async (delegate: Delegate, tag: Tag) => {
		// The old relation one might want to be changing who one is delegating to within a tag
		const oldRelation = delegateRelations.find((relation) =>
			relation.tags.find((_tag) => _tag.id === tag.id)
		)?.delegate_pool_id;

		// If we find such an old delegation, remove it and add the new one
		if (oldRelation) await saveDelegation(oldRelation, tag.id, 'remove', false);
		await saveDelegation(delegate.pool_id, tag.id);
	};

	const getGroupTags = async () => {
		// TODO: What happends when limit has been reached?
		// Potential fix here and at other places: Max number of tags per group?
		const { res, json } = await fetchRequest('GET', `group/${group.id}/tags?limit=1000`);
		if (!res.ok) return;
		tags = json?.results;
	};

	const getDelegates = async () => {
		const { json, res } = await fetchRequest('GET', `group/${group.id}/delegate/pools?limit=1000`);
		if (!res.ok) return;

		// Temporary fix to make each delegate pool be associated with one user.
		// TODO: Remove pools in the backend
		delegates = json?.results.map((delegatePool: any) => {
			return { ...delegatePool.delegates[0].group_user, pool_id: delegatePool.id };
		});
	};

	const getDelegateRelations = async () => {
		const { json, res } = await fetchRequest('GET', `group/${group.id}/delegates?limit=1000`);

		if (!res.ok) return;

		delegateRelations = json?.results;
	};

	const createDelegateRelation = async (delegate_pool_id: number) => {
		const { json, res } = await fetchRequest('POST', `group/${group.id}/delegate/create`, {
			delegate_pool_id
		});
	};

	// When a user clicks on a tag they want to delegate to, delegate to that tag
	const saveDelegation = async (
		delegate: number,
		tag: number,
		action: 'add' | 'remove' = 'add',
		successMessage = true
	) => {
		let relation: DelegateRelation | undefined = delegateRelations.find(
			(relation) => relation.delegate_pool_id === delegate
		);

		if (relation === undefined) return;

		const payload = {
			delegate_pool_id: relation.delegate_pool_id,
			tags:
				action === 'add'
					? [...relation.tags.map((_tag) => _tag.id), tag]
					: // If remove, filter it away
						[...relation.tags.filter((_tag) => _tag.id !== tag).map((_tag) => _tag.id)]
		};

		const { res } = await fetchRequest('POST', `group/${group.id}/delegate/update`, payload);

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Failed to save new delegation', success: false });
			return;
		}

		// Because of scuffness in the code, saveDelegation is called twice, once to remove an earlier delegation and once more to add the new one.
		// As such, two messages appear if we don't do this.
		if (successMessage)
			ErrorHandlerStore.set({ message: 'Successfully saved delegation', success: true });
	};

	const notificationSubscribe = async (pool_id: number) => {
		//TODO Unsubscribe when removing delegation
		const { json, res } = await fetchRequest(
			'POST',
			`group/delegate/pool/${pool_id}/notification/subscribe`,
			{
				tags: ['poll_vote_update']
			}
		);
	};
</script>

<Loader bind:loading>
	<div>
		{#if delegates.length > 0}
			{#each tags as tag, index}
				<div class="section">
					<button
						type="button"
						class="transition-all flex text-primary dark:text-secondary justify-between w-full section-title"
						on:click={() => (expandedSection = expandedSection === index ? null : index)}
					>
						<span class="break-word text-left">{tag.name}</span>

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
										displayName
										username={delegate.user.username}
										userId={delegate.user.id}
										profilePicture={delegate.user.profile_image}
										href={`/user?id=${delegate.user.id}&delegate_id=${delegate.id}&group_id=${group.id}&is_admin=${delegate.is_admin}`}
									/>

									<span>
										<input
											disabled={delegates.find((delegate) => delegate.user.id === $userStore?.id) &&
												delegate.user.id !== $userStore?.id}
											on:input={async () => {
												loading = true;
												await createDelegateRelation(delegate.pool_id);
												await getDelegateRelations();
												await updateDelgation(delegate, tag);
												await notificationSubscribe(delegate.pool_id);
												// Refresh relations to ensure consistency with backend
												await getDelegateRelations();
												loading = false;
											}}
											type="radio"
											name={tag.name}
											checked={delegateRelations
												.find((relation) => relation.delegate_pool_id === delegate.pool_id)
												?.tags.find((_tag) => _tag.id === tag.id) !== undefined}
										/>
									</span>
								</div>
							{/each}
						</div>
						<button
							class="text-red-700 hover:underline"
							on:click={async () => {
								const delegateRelationToRemove = delegateRelations.find((relation) =>
									relation.tags.find((_tag) => _tag.id === tag.id)
								);

								if (delegateRelationToRemove) {
									await saveDelegation(delegateRelationToRemove.delegate_pool_id, tag.id, 'remove');
									groupDelegationSetup();
								}
							}}>{$_('Clear Choice')}</button
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
</Loader>

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
