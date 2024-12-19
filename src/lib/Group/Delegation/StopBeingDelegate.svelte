<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import { _ } from 'svelte-i18n';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { Delegate } from './interfaces';

	export let userIsDelegate: boolean,
		loading: boolean,
		groupId: number,
		delegates: Delegate[],
		Class = '';
	let poppup: poppup;

	const deleteDelegation = async () => {
		await deleteDelegationPool();
		getDelegatePools();
		userIsDelegate = false;
	};

	/*
		Makes the currently logged in user no longer a delegate(pool)
	*/
	const deleteDelegationPool = async () => {
		loading = true;
		const { res } = await fetchRequest('POST', `group/${groupId}/delegate/pool/delete`);
		loading = false;

		if (!res.ok) return;

		userIsDelegate = false;
		// userIsDelegateStore.update((value) => (value = false));
	};

	/*
		Temporary fix to make each delegate pool be associated with one user.
		TODO: Implement delegate pool feature in the front end (Figma design first)
	*/
	const getDelegatePools = async () => {
		loading = true;
		const { json, res } = await fetchRequest('GET', `group/${groupId}/delegate/pools?limit=1000`);

		if (!res.ok) {
			poppup = { message: "Couldn't get delegation pools", success: false };
			return;
		}

		delegates = json.results.map((delegatePool: any) => {
			return { ...delegatePool.delegates[0].group_user, pool_id: delegatePool.id };
		});

		loading = false;
	};
</script>

<Button Class={`bg-red-500 ${Class}`} action={deleteDelegation}>{$_('Stop being delegate')}</Button>
<Poppup bind:poppup />
