<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { Group, Tag } from '$lib/Group/interface';
	import type { Delegate, DelegateRelation } from './interfaces';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faClockRotateLeft } from '@fortawesome/free-solid-svg-icons';
	import { userStore } from '$lib/User/interfaces';
	import Loader from '$lib/Generic/Loader.svelte';

	export let group: Group,
		delegates: Delegate[] = [];

	let tags: Tag[] = [],
		expandedSection: any = true,
		delegateRelations: DelegateRelation[] = [],
		loading = false,
		pendingCheck: Record<string, number | null> = {};

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
		const { res, json } = await fetchRequest(
			'GET',
			`group/${group.id}/tags?limit=1000`
		);
		if (!res.ok) return;
		tags = json?.results;
	};

	const getDelegates = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${group.id}/delegate/pools?limit=1000`
		);
		if (!res.ok) return;

		// Temporary fix to make each delegate pool be associated with one user.
		// TODO: Remove pools in the backend
		delegates = json?.results.map((delegatePool: any) => {
			return {
				...delegatePool.delegates[0].group_user,
				pool_id: delegatePool.id
			};
		});
	};

	const getDelegateRelations = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${group.id}/delegates?limit=1000`
		);

		if (!res.ok) return;

		delegateRelations = json?.results;
	};

	const createDelegateRelation = async (delegate_pool_id: number) => {
		const { json, res } = await fetchRequest(
			'POST',
			`group/${group.id}/delegate/create`,
			{
				delegate_pool_id
			}
		);
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
						[
							...relation.tags
								.filter((_tag) => _tag.id !== tag)
								.map((_tag) => _tag.id)
						]
		};

		const { res } = await fetchRequest(
			'POST',
			`group/${group.id}/delegate/update`,
			payload
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to save new delegation',
				success: false
			});
			return;
		}

		// Because of scuffness in the code, saveDelegation is called twice, once to remove an earlier delegation and once more to add the new one.
		// As such, two messages appear if we don't do this.
		if (successMessage)
			ErrorHandlerStore.set({
				message: 'Successfully saved delegation',
				success: true
			});
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

	const clearChoice = async (tag: Tag) => {
		const delegateRelationToRemove = delegateRelations.find((relation) =>
			relation.tags.find((_tag) => _tag.id === tag.id)
		);

		if (delegateRelationToRemove) {
			pendingCheck[tag.name] = null;
			pendingCheck = pendingCheck;
			await saveDelegation(
				delegateRelationToRemove.delegate_pool_id,
				tag.id,
				'remove'
			);
			delete pendingCheck[tag.name];
			pendingCheck = pendingCheck;
			groupDelegationSetup();
		}
	};
</script>

<Loader bind:loading>
	<div>
		{#if delegates.length > 0}
			{#each tags as tag, index}
				{#if index === 0}
					<div>
						<span class="text-primary dark:text-secondary font-medium">{$_('Delegates')}</span>

						<div class="flex flex-col gap-2 mt-2">
							{#each delegates as delegate}
								{@const isChecked = tag.name in pendingCheck
									? pendingCheck[tag.name] === delegate.pool_id
									: delegateRelations
										.find(r => r.delegate_pool_id === delegate.pool_id)
										?.tags.find(_tag => _tag.id === tag.id) !== undefined}
								<label
									class="flex items-center justify-between p-3 rounded-xl border cursor-pointer transition-colors
										{isChecked
											? 'bg-primary/5 border-primary/30 dark:bg-primary/10 dark:border-primary/40'
											: 'border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-darkbackground'}"
								>
									<ProfilePicture
										displayName
										username={delegate.user.username}
										userId={delegate.user.id}
										profilePicture={delegate.user.profile_image}
										href={`/user?id=${delegate.user.id}&delegate_id=${delegate.id}&group_id=${group.id}&is_admin=${delegate.is_admin}`}
									/>
									<div class="flex items-center gap-3 shrink-0">
										<a
											href={`/user?id=${delegate.user.id}&delegate_id=${delegate.id}&group_id=${group.id}&is_admin=${delegate.is_admin}`}
											class="flex items-center gap-1.5 text-xs text-gray-400 hover:text-primary dark:hover:text-secondary transition-colors px-2 py-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700"
											on:click|stopPropagation
										>
											<Fa icon={faClockRotateLeft} />
											<span>{$_('History')}</span>
										</a>
										<input
											disabled={delegates.find(d => d.user.id === $userStore?.id) && delegate.user.id !== $userStore?.id}
											on:input={async () => {
												pendingCheck[tag.name] = delegate.pool_id;
												pendingCheck = pendingCheck;
												loading = true;
												await createDelegateRelation(delegate.pool_id);
												await getDelegateRelations();
												await updateDelgation(delegate, tag);
												await notificationSubscribe(delegate.pool_id);
												await getDelegateRelations();
												delete pendingCheck[tag.name];
												pendingCheck = pendingCheck;
												loading = false;
											}}
											type="radio"
											name={tag.name}
											checked={isChecked}
											class="accent-primary w-4 h-4"
										/>
									</div>
								</label>
							{/each}
						</div>
						<button
							class="text-xs text-red-400 hover:text-red-600 hover:underline transition-colors mt-2"
							on:click={() => clearChoice(tag)}
						>
							{$_('Clear Choice')}
						</button>
					</div>
				{/if}
			{/each}
		{:else}
			<span>{$_('There are currently no delegates for this group')}</span>
		{/if}
	</div>
</Loader>
