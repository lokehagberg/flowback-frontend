<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Loader from '$lib/Generic/Loader.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import type { DelegatePool, VoteHistory } from './interfaces';
	import { _ } from 'svelte-i18n';
	import Comments from '$lib/Comments/Comments.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import { userStore } from '$lib/User/interfaces';
	import Structure from '$lib/Poll/NewDesign/Structure.svelte';
	import type { PredictionStatement } from '$lib/Poll/PredictionMarket/interfaces';

	export let history: null | number,
		groupId = 0;

	let loading = false,
		delegatePool: DelegatePool,
		votingHistory: VoteHistory[] = [],
		filteredVotingHistory: VoteHistory[] = [],
		searchVoteQuery = '',
		searched = false,
		sortOrder: 'a-z' | 'z-a' = 'a-z',
		predictions: PredictionStatement[] = [];

	const getDelegateHistory = async () => {
		loading = true;
		const { json, res } = await fetchRequest(
			'GET',
			`group/poll/pool/votes?group_id=${groupId}&include_details=true`
		);
		loading = false;
		if (!res.ok) return;

		votingHistory = json?.results;
		filteredVotingHistory = [...json?.results];
	};

	const getDelegateInfo = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId || groupId}/delegate/pools?id=${history}`
		);

		delegatePool = json?.results[0];
	};

	$: {
		if (filteredVotingHistory.length > 0) {
		}
	}

	const getPredictionStatements = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${groupId}/poll/prediction/statement/list`
		);

		if (!res.ok) return;

		predictions = json?.results;
	};

	const searchVotes = async (query: string) => {
		searched = true;

		if (query === '') {
			filteredVotingHistory = [...votingHistory];
		}
	};

	const resetFilter = () => {
		searchVoteQuery = '';
		sortOrder = 'a-z';
		filteredVotingHistory = [...votingHistory];
		searched = false;
	};

	onMount(async () => {
		await getDelegateInfo();
		await getDelegateHistory();
		await getPredictionStatements();
	});
</script>

<Loader bind:loading>
	<div class="w-screen bg-[#faf5ff] dark:bg-darkbackground pt-4 p-4">
		<div
			class="w-full max-w-screen-md mx-auto p-4 bg-white dark:bg-darkobject rounded shadow mb-4"
		>
			<span class="text-sm text-gray-700 dark:text-darkmodeText pb-2">
				{$_('Delegate history for')}
				{$userStore?.username}
			</span>
			<form
				class="w-full dark:bg-darkobject dark:text-darkmodeText flex flex-1 items-end gap-4"
				on:input|preventDefault={() => searchVotes(searchVoteQuery)}
			>
				<div class="flex-col w-full pt-2">
					<TextInput
						Class="w-full dark:text-gray-300 dark:bg-gray-800 dark:border-gray-600"
						onInput={() => (searched = false)}
						label=""
						max={null}
						search={true}
						placeholder={$_('Search polls')}
						bind:value={searchVoteQuery}
					/>

					<div class="flex flex-row items-center gap-1 pt-2">
						<span class="text-gray-700 dark:text-gray-300">{$_('Sort')}: </span>
						<Select
							classInner="p-1 dark:text-gray-300 dark:bg-gray-800 dark:border-gray-600"
							labels={[$_('A - Z'), $_('Z - A')]}
							values={['a-z', 'z-a']}
							bind:value={sortOrder}
						/>

						<div class="rounded-md p-1 ml-auto">
							<Button
								Class="!p-1 border-none text-red-600 dark:text-red-400 cursor-pointer hover:underline"
								buttonStyle="warning-light"
								onClick={resetFilter}
							>
								{$_('Reset Filter')}
							</Button>
						</div>
					</div>
				</div>
			</form>
		</div>

		<Structure Class="mx-auto !p-6 !pt-0 max-w-screen-xl" showRight showBoth>
			<div
				slot="left"
				class="p-4 bg-white dark:bg-darkobject rounded shadow max-h-[100%] overflow-auto"
			>
				{#if filteredVotingHistory.length > 0}
					<ul class="w-full">
						{#each filteredVotingHistory as voteHistory}
							<li
								class="bg-white dark:bg-darkobject dark:text-darkmodeText p-3 w-full border-b last:border-b-0 dark:border-gray-600"
							>
								<div class="flex flex-col gap-2">
									<a
										class="w-full break-words text-left text-xl p-1 pl-0 text-gray-900 dark:text-gray-300 cursor-pointer hover:underline"
										href={`groups/${new URLSearchParams(
											window.location.search
										).get(
											'group_id'
										)}/polls/${voteHistory?.poll.id}?source=delegate-history`}
									>
										{voteHistory?.poll.title || $_('No title')}
									</a>

									{#if voteHistory?.poll.description}
										<div class="text-sm text-gray-600 dark:text-gray-400 pl-1">
											<p class="line-clamp-2">
												{voteHistory?.poll.description}
											</p>
										</div>
									{/if}

									{#each voteHistory.vote as vote}
										{@const predictionsForProp = predictions.filter((p) =>
											p.segments.find((s) => s.proposal_id === vote.proposal_id)
										)}
										<div class="mt-2 p-2 bg-gray-50 dark:bg-gray-800 rounded">
											<div>{vote.proposal_title}</div>
											<div>{vote.proposal_description}</div>
											<div>{$_('Delegate voted:')} {vote.raw_score}</div>
											{#each predictionsForProp as prediction}
												<div
													class="mt-1 p-2 bg-gray-100 dark:bg-gray-700 rounded"
												>
													{prediction?.title}
													{prediction?.description}
													{prediction?.combined_bet}
												</div>
											{/each}
										</div>
									{/each}
								</div>
							</li>
						{/each}
					</ul>
				{:else if filteredVotingHistory.length === 0 && searched}
					<div class="p-3 text-center text-gray-500 dark:text-gray-400">
						{$_('No polls match your search criteria')}
					</div>
				{:else}
					<div class="p-3 text-center text-gray-500 dark:text-gray-400">
						{$_('No delegate history')}
					</div>
				{/if}
			</div>
			<div slot="right" class="p-4">
				<Comments
					Class="bg-white dark:bg-darkobject p-4 shadow dark:text-darkmodeText"
					api="delegate-history"
					on:keydown={() => {}}
					delegate_pool_id={history}
				/>
			</div>
		</Structure>
	</div>
</Loader>
