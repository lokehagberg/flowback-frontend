<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Loader from '$lib/Generic/Loader.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import type { DelegatePool, VoteHistory } from './interfaces';
	import { _ } from 'svelte-i18n';
	import type { User } from '$lib/User/interfaces';
	import { goto } from '$app/navigation';
	import Comments from '$lib/Comments/Comments.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Select from '$lib/Generic/Select.svelte';

	export let history: null | number,
		groupId = 0;

	let loading = false,
		delegatePool: DelegatePool,
		votingHistory: VoteHistory[] = [],
		filteredVotingHistory: VoteHistory[] = [],
		user: User,
		searchVoteQuery = '',
		searched = false,
		sortOrder: 'a-z' | 'z-a' = 'a-z';

	const getDelegateHistory = async () => {
		loading = true;
		console.log('history', history, delegatePool);
		const { json, res } = await fetchRequest('GET', `group/poll/pool/votes?group_id=${history}`);
		loading = false;
		if (res.ok) {
			votingHistory = json.results;
			filteredVotingHistory = [...json.results];
			sortVoteHistory();
		}
	};

	const getDelegateInfo = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId || groupId}/delegate/pools?id=${history}`
		);

		delegatePool = json.results[0];
	};

	const getUserInfo = async () => {
		const { res, json } = await fetchRequest('GET', `users?id=${$page.url.searchParams.get('id')}`);

		if (!res.ok) return {};
		user = json.results[0];
	};
	
	const sortVoteHistory = () => {
		console.log("Sorting with order:", sortOrder);
		if (sortOrder === 'a-z') {
			filteredVotingHistory = [...filteredVotingHistory].sort((a, b) => 
				a.poll_title.toLowerCase().localeCompare(b.poll_title.toLowerCase())
			);
		} else if (sortOrder === 'z-a') {
			filteredVotingHistory = [...filteredVotingHistory].sort((a, b) => 
				b.poll_title.toLowerCase().localeCompare(a.poll_title.toLowerCase())
			);
		}
		console.log("Sorted results:", filteredVotingHistory.map(v => v.poll_title));
	};
	
	$: {
		if (filteredVotingHistory.length > 0) {
			console.log("Sort order changed to:", sortOrder);
			sortVoteHistory();
		}
	}
	
	const searchVotes = async (query: string) => {
		searched = true;
		
		if (query === '') {
			filteredVotingHistory = [...votingHistory];
		} else {
			filteredVotingHistory = votingHistory.filter(vote => 
				vote.poll_title.toLowerCase().includes(query.toLowerCase())
			);
		}
		
		sortVoteHistory();
	};
	
	const resetFilter = () => {
		searchVoteQuery = '';
		sortOrder = 'a-z';
		filteredVotingHistory = [...votingHistory];
		searched = false;
		sortVoteHistory();
	};

	const handleSortChange = () => {
		console.log("Sort changed manually to:", sortOrder);
		sortVoteHistory();
	};

	onMount(async () => {
		await getDelegateInfo();
		await getDelegateHistory();
		await getUserInfo();

		let query = new URLSearchParams($page.url.searchParams.toString());
		query.set('history_id', delegatePool.id.toString());
		goto(`?${query.toString()}`);
	});
</script>

<Loader bind:loading>
	<div class="w-screen bg-[#faf5ff] pt-4">
		<div class="w-full max-w-screen-md mx-auto p-4 bg-white rounded shadow mb-4">
			<span class="font-semibold text-sm text-gray-700 pb-2">{$_('Delegate history for')} {user?.username}</span>
			<form
				class="w-full dark:bg-darkobject dark:text-darkmodeText flex flex-1 items-end gap-4"
				on:input|preventDefault={() => searchVotes(searchVoteQuery)}
			>
				<div class="flex-col w-full pt-2">
					<TextInput
						Class="w-full"
						onInput={() => (searched = false)}
						label=""
						max={null}
						search={true}
						placeholder={$_('Search polls')}
						bind:value={searchVoteQuery}
					/>

					<div class="flex flex-row items-center gap-1 pt-2">
						<span>{$_('Sort')}: </span>
						<Select
							classInner="p-1 font-semibold"
							labels={[$_('A - Z'), $_('Z - A')]}
							values={['a-z', 'z-a']}
							bind:value={sortOrder}
							onInput={handleSortChange}
						/>

						<div class="rounded-md p-1 ml-auto">
							<Button
								Class="!p-1 border-none text-red-600 cursor-pointer hover:underline"
								buttonStyle="warning-light"
								onClick={resetFilter}>{$_('Reset Filter')}</Button
							>
						</div>
					</div>
				</div>
			</form>
		</div>
		<div class="w-full max-w-screen-md mx-auto p-4 bg-white rounded shadow">
			<ul class="w-full">
				{#if filteredVotingHistory.length > 0}
					{#each filteredVotingHistory as vote}
						<li
							class="bg-white dark:bg-darkobject dark:text-darkmodeText p-3 w-full flex justify-between items-center border-b last:border-b-0"
						>
							<button
								class="w-full break-words text-left text-xl p-1 pl-0 dark:text-darkmodeText cursor-pointer hover:underline"
								on:click={() =>
									goto(`groups/${delegatePool.delegates[0].group_user.group_id}/polls/${vote.poll_id}`)}
							>
								{vote.poll_title}
							</button>
						</li>
					{/each}
				{:else}
					<li class="p-3 text-center text-gray-500">
						{$_('No polls match your search criteria')}
					</li>
				{/if}
			</ul>
		</div>
		<div class="p-4 w-full max-w-screen-md mx-auto">
			<Comments Class="bg-white p-4 shadow" api="delegate-history" on:keydown={() => {}} delegate_pool_id={history} />
		</div>
	</div>
</Loader>