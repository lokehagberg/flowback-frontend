<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import type { Delegate } from './interfaces';
	import type { GroupUser } from '$lib/Group/interface';
	import { onMount } from 'svelte';

	export let groupUser: GroupUser,
		loading: boolean,
		groupId: number,
		delegates: Delegate[],
		Class = '',
		tags: number[] = [];

	let selfDelegated = false;

	const getSelfDelegationStatus = async () => {
		if (!groupUser?.delegate_pool_id) {
			selfDelegated = false;
			return;
		}

		const { json, res } = await fetchRequest(
			'GET',
			`group/${groupId}/delegates?limit=1000`
		);

		if (!res.ok) return;

		selfDelegated = json?.results.some(
			(relation: { delegate_pool_id: number; tags: { id: number }[] }) =>
				relation.delegate_pool_id === groupUser.delegate_pool_id &&
				relation.tags.length > 0
		);
	};

	onMount(() => {
		getSelfDelegationStatus();
	});

	$: if (groupId && groupUser?.delegate_pool_id) {
		getSelfDelegationStatus();
	}

	const deleteDelegation = async () => {
		await deleteDelegationPool();
		await getDelegatePools();
		groupUser.delegate_pool_id = null;
		selfDelegated = false;
	};

	/*
		Makes the currently logged in user no longer a delegate(pool)
	*/
	const deleteDelegationPool = async () => {
		loading = true;
		const { res } = await fetchRequest(
			'POST',
			`group/${groupId}/delegate/pool/delete`
		);
		loading = false;

		if (!res.ok) return;

		groupUser.delegate_pool_id = null;
		// userIsDelegateStore.update((value) => (value = false));
	};

	const selfDelegate = async () => {
		if (loading || selfDelegated) return;

		loading = true;

		// Create delegation relation to oneself
		{
			const { res } = await fetchRequest(
				'POST',
				`group/${groupId}/delegate/create`,
				{
					delegate_pool_id: groupUser.delegate_pool_id
				}
			);

			if (!res.ok) {
				loading = false;
				return;
			}
		}

		// Get Group Tags
		{
			// TODO: What happends when limit has been reached?
			// Potential fix here and at other places: Max number of tags per group?
			const { res, json } = await fetchRequest(
				'GET',
				`group/${groupId}/tags?limit=1000`
			);

			if (!res.ok) {
				ErrorHandlerStore.set({
					message: "Couldn't create self-delegation",
					success: false
				});
				loading = false;
				return;
			}

			tags = json?.results.map((tag: any) => tag.id);
		}

		// Update delegation to self with all tags
		{
			const { res } = await fetchRequest(
				'POST',
				`group/${groupId}/delegate/update`,
				{
					tags,
					delegate_pool_id: groupUser.delegate_pool_id
				}
			);

			if (!res.ok) {
				ErrorHandlerStore.set({
					message: "Couldn't create self-delegation",
					success: false
				});
				loading = false;
				return;
			}
		}

		ErrorHandlerStore.set({
			message: 'Successfully self-delegated',
			success: true
		});
		selfDelegated = true;
		loading = false;
	};

	/*
		Temporary fix to make each delegate pool be associated with one user.
		TODO: Implement delegate pool feature in the front end (Figma design first)
	*/
	const getDelegatePools = async () => {
		loading = true;
		const { json, res } = await fetchRequest(
			'GET',
			`group/${groupId}/delegate/pools?limit=1000`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: "Couldn't get delegation pools",
				success: false
			});
			loading = false;
			return;
		}

		delegates = json?.results.map((delegatePool: any) => {
			return {
				...delegatePool.delegates[0].group_user,
				pool_id: delegatePool.id
			};
		});

		loading = false;
	};
</script>

<div class="flex flex-col gap-3 {Class}">
	<!-- Self-delegate -->
	<div
		class="p-4 rounded-xl bg-gray-50 dark:bg-darkbackground border border-gray-200 dark:border-gray-700 flex items-center justify-between gap-3"
	>
		<div>
			<p class="text-sm font-medium text-gray-700 dark:text-darkmodeText">
				{$_('Self-Delegate')}
			</p>
			<p class="text-xs text-gray-400 mt-0.5">
				{$_('Vote automatically as yourself')}
			</p>
		</div>
		<Button onClick={selfDelegate} buttonStyle="primary-light"
			disabled={loading || selfDelegated}
			>{$_(selfDelegated ? 'Applied' : 'Apply')}</Button
		>
	</div>

	<!-- Stop being delegate (destructive) -->
	<div
		class="p-4 rounded-xl bg-red-50 dark:bg-red-950/20 border border-red-200 dark:border-red-800/40 flex items-center justify-between gap-3"
	>
		<div>
			<p class="text-sm font-medium text-red-700 dark:text-red-400">
				{$_('Stop being delegate')}
			</p>
			<p class="text-xs text-red-400/80 mt-0.5">
				{$_('Remove your delegate status from this group')}
			</p>
		</div>
		<Button onClick={deleteDelegation} buttonStyle="warning"
			>{$_('Leave')}</Button
		>
	</div>
</div>
