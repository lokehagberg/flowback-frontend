<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import type { Delegate } from './interfaces';
	import type { GroupUser } from '$lib/Group/interface';

	export let groupUser: GroupUser,
		loading: boolean,
		groupId: number,
		delegates: Delegate[],
		Class = '',
		tags: number[] = [];

	const deleteDelegation = async () => {
		await deleteDelegationPool();
		getDelegatePools();
		groupUser.delegate_pool_id = null;
	};

	/*
		Makes the currently logged in user no longer a delegate(pool)
	*/
	const deleteDelegationPool = async () => {
		loading = true;
		const { res } = await fetchRequest('POST', `group/${groupId}/delegate/pool/delete`);
		loading = false;

		if (!res.ok) return;

		groupUser.delegate_pool_id = null;
		// userIsDelegateStore.update((value) => (value = false));
	};

	const selfDelegate = async () => {
		loading = true;

		// Create delegation relation to oneself
		{
			const { json, res } = await fetchRequest('POST', `group/${groupId}/delegate/create`, {
				delegate_pool_id: groupUser.delegate_pool_id
			});

			if (!res.ok) loading = false;
		}

		// Get Group Tags
		{
			// TODO: What happends when limit has been reached?
			// Potential fix here and at other places: Max number of tags per group?
			const { res, json } = await fetchRequest('GET', `group/${groupId}/tags?limit=1000`);

			if (!res.ok) {
				ErrorHandlerStore.set({ message: "Couldn't create self-delegation", success: false });
				loading = false;
				return;
			}

			tags = json?.results.map((tag: any) => tag.id);
		}

		// Update delegation to self with all tags
		{
			const { res } = await fetchRequest('POST', `group/${groupId}/delegate/update`, {
				tags,
				delegate_pool_id: groupUser.delegate_pool_id
			});

			if (!res.ok) {
				ErrorHandlerStore.set({ message: "Couldn't create self-delegation", success: false });
				loading = false;
				return;
			}
		}

		ErrorHandlerStore.set({ message: 'Successfully self-delegated', success: true });
		loading = false;
	};

	/*
		Temporary fix to make each delegate pool be associated with one user.
		TODO: Implement delegate pool feature in the front end (Figma design first)
	*/
	const getDelegatePools = async () => {
		loading = true;
		const { json, res } = await fetchRequest('GET', `group/${groupId}/delegate/pools?limit=1000`);

		if (!res.ok) {
			ErrorHandlerStore.set({ message: "Couldn't get delegation pools", success: false });
			return;
		}

		delegates = json?.results.map((delegatePool: any) => {
			return { ...delegatePool.delegates[0].group_user, pool_id: delegatePool.id };
		});

		loading = false;
	};
</script>

<Button Class={`bg-red-500 ${Class}`} onClick={deleteDelegation}>{$_('Stop being delegate')}</Button
>
<Button onClick={selfDelegate}>{'Self-Delegate'}</Button>
