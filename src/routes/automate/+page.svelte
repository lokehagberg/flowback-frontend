<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Toggle from '$lib/Generic/Toggle.svelte';
	import type { Delegate } from '$lib/Group/Delegation/interfaces';
	import NewerDelegaions from '$lib/Group/Delegation/NewerDelegations.svelte';
	import StopBeingDelegate from '$lib/Group/Delegation/StopBeingDelegate.svelte';
	import type { Group } from '$lib/Group/interface';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	let group: Group,
		userIsDelegate = false,
		loading = false,
		delegates: Delegate[] = [],
		selectedPage: 'become-delegate' | 'delegate' | 'none' = 'none';

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
		await getUserInfo();
		selectedPage = userIsDelegate ? 'become-delegate' : 'delegate';
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
				<!-- <li><input type="checkbox" /> {$_('Auto-choose meeting times')}</li> -->
				<li>
					<input
						type="checkbox"
						on:input={() => (selectedPage = 'delegate')}
						disabled={userIsDelegate}
					/>

					<Toggle checked />
					{$_('Auto-vote')}
					<p>
						{$_(
							'Auto-voting means that you automatically vote the same as someone you trust. You can auto-vote according to how public voters have voted in specific topics. You can always change your vote afterwards if you have time and want to.'
						)}
					</p>

					<Button
						Class="w-full mt-3"
						action={() => (selectedPage = 'become-delegate')}
						buttonStyle="primary-light">{$_('Become delegate')}</Button
					>
				</li>
				<!-- <li><input type="checkbox" /> {$_('Smart secretary')}</li> -->
			</ul>
		</div>
		<div class="bg-white p-6 shadow flex-grow">
			{#if selectedPage === 'become-delegate'}
				{$_(
					'As a public voter, you choose to publicly show everyone how you vote. Choose within which subject areas you want to become a public voter below. As a public voter, we recommend that you make some of the value compasses created by members. How to answer questions in them value compasses that exist are used as a basis for matching you with other users on Reform forum.'
				)}

				{#if userIsDelegate}
					<StopBeingDelegate
						Class="w-full mt-3"
						bind:delegates
						bind:userIsDelegate
						groupId={group.id}
						bind:loading
					/>
				{:else}
					<Button Class="w-full mt-3" action={createDelegationPool} buttonStyle="primary-light"
						>{$_('Become delegate')}</Button
					>
				{/if}
			{:else if selectedPage === 'delegate'}
				{#if group?.id}
					<NewerDelegaions bind:group bind:delegates />
				{/if}
			{/if}
		</div>
	</div>
</Layout>
