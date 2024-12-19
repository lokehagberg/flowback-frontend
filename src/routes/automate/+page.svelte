<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import type { Delegate } from '$lib/Group/Delegation/interfaces';
	import NewerDelegaions from '$lib/Group/Delegation/NewerDelegations.svelte';
	import StopBeingDelegate from '$lib/Group/Delegation/StopBeingDelegate.svelte';
	import type { Group } from '$lib/Group/interface';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	let group: Group,
		userIsDelegate = false,
		loading = false,
		delegates: Delegate[] = [];

	const getGroups = async () => {
		const { res, json } = await fetchRequest('GET', `group/list`);

		if (!res.ok) return;
		group = json.results[0];
	};

	const getUserInfo = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${group.id}/users?user_id=${localStorage.getItem('userId')}&delegate=true`
		);
		if (json.results.length === 1) userIsDelegate = true;
	};

	/*
	 	Makes the currently logged in user into a delegate(pool)
	 */
	const createDelegationPool = async () => {
		// let toSend: any = {};

		// if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE')
		// 	try {
		// 		const blockchain_id = becomeDelegate($page.params.groupId);
		// 		if (isNumber(blockchain_id)) toSend.blockchain_id = blockchain_id;
		// 	} catch {
		// 		toSend.blockchain_id = 4;
		// 		console.warn('Error');
		// 	}

		const { res } = await fetchRequest('POST', `group/${group.id}/delegate/pool/create`, {});

		if (!res.ok) return;
		userIsDelegate = true;
	};

	onMount(async () => {
		await getGroups();
		getUserInfo();
	});
</script>

<Layout centered>
	<div class="bg-white p-6 shadow w-full text-left">
		<h1 class="text-xl font-semibold text-primary text-left">{$_('Automate')}</h1>
		<p>
			{$_(
				`Sometimes we have limited time and cannot participate fully, but still want to contribute. Reformum has a number of functions to automate parts of your engagement when you cannot participate yourself.`
			)}
		</p>
	</div>
	<div class="flex w-[80%] my-6 gap-6">
		<div class="bg-white p-6 shadow">
			<ul>
				<li><input type="checkbox" /> {$_('Auto-choose meeting times')}</li>
				<li>
					<input type="checkbox" />
					{$_('Auto-vote')}
					{#if userIsDelegate}
						<StopBeingDelegate bind:delegates bind:userIsDelegate groupId={group.id} bind:loading />
					{:else}
						<Button action={createDelegationPool} buttonStyle="primary-light"
							>{$_('Become delegate')}</Button
						>
					{/if}
					<p>
						Auto-röstning innebär att du automatiskt röstar likadant som någon du har förtroende
						för. Du kan auto-rösta i enlighet med hur offentliga röstare har röstat i specifika
						ämnesområden. Du kan alltid ändra din röst i efterhand om du har tid och vill.
					</p>
				</li>
				<li><input type="checkbox" /> {$_('Smart secretary')}</li>
			</ul>
		</div>

		<div class="bg-white p-6 shadow flex-grow">
			{#if group}
				<NewerDelegaions bind:group bind:delegates />
			{/if}
		</div>
	</div>
</Layout>
