<script lang="ts">
	import { onMount } from 'svelte';
	import Proposal from './Proposal.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faArrowDown } from '@fortawesome/free-solid-svg-icons/faArrowDown';
	import { faArrowUp } from '@fortawesome/free-solid-svg-icons/faArrowUp';
	import { faMinus } from '@fortawesome/free-solid-svg-icons/faMinus';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import type { proposal, votings } from './interface';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import Button from '$lib/Generic/Button.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { mode } from '$lib/configuration';
	import { _ } from 'svelte-i18n';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { formatDate } from './functions';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import Toggle from '$lib/Generic/Toggle.svelte';

	export let votings: votings[];
	export let selectedPage: 'You' | 'Delegate';
	export let abstained: proposal[] = [];
	//1 is ranked, 3 is scheduled
	export let pollType: number = 1,
		votingStartTime: string;
	let proposals: proposal[] = [];
	let ranked: proposal[] = [];
	let selected: proposal;
	let checked = false;

	export let tag: number;

	let unsaved = false;
	let status: StatusMessageInfo;

	$: selectedPage && setUpVotings();

	/*The Draggable package does not like reactive states, 
	so we use non-reactive code in this file.*/
	onMount(async () => {
		setUpSortable();
		await getProposals();
		setUpVotings();
	});

	const setUpVotings = async () => {
		if (selectedPage === 'You') await getVotings();
		else if (selectedPage === 'Delegate') await getDelegateVotings();
		setOrdering();
	};

	const getProposals = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposals?limit=100`
		);

		//Ranked
		if (pollType === 1) proposals = json.results;
		//Scheduled
		else if (pollType === 3)
			proposals = json.results.map((proposal: any) => {
				return { description: proposal.end_date, title: proposal.start_date, id: proposal.id };
			});
	};

	const setUpSortable = async () => {
		const { Sortable } = await import('@shopify/draggable');

		const containers = [
			document.querySelector('.container.abstained'),
			document.querySelector('.container.ranked')
		];

		const sortable = new Sortable(containers, {
			draggable: 'li',
			classes: {
				mirror: ['draggable--over', 'bg-red-200', 'bg-opacity-25']
			}
		});

		/*
			Whenever the user stops dragging it updates the state of ranked or abstained based 
			on where the user dragged it too.	
		*/

		sortable.on('sortable:start', (e: any) => {
			if (checked) e.cancel();
		});

		sortable.on('sortable:stop', async (e: any) => {
			console.log(e, 'STOPPED');
			// e.data.dragEvent.data.originalSource.remove();

			// if (selected)
			// addToRanked(selected)
			// setTimeout(() => {
			// }, 1000);
		});

		sortable.on('sortable:sorted', async (e: any) => {
			unsaved = true;

			console.log(e, 'SORTED');
		});

		

		sortable.on('sortable:start', (e: any) => {
			if (selectedPage === 'Delegate' || checked) {
				e.cancel();
			}
		});

		sortable.on('drag:stopped', (e: any) => {
			console.log(e);
		});
	};

	/*
		Every voting has a priority, larger number means higher up in the ranking.
		We find whether or not a proposal has been ranked, and then put it in the right slot
		in "ranked", otherwise it's put in "abstained"
	*/
	const setOrdering = () => {
		if (!votings) return;

		// ranked = new Array(votings.length);
		ranked = [];
		abstained = [];

		proposals.forEach((proposal) => {
			const vote = votings.find((vote) => proposal.id === vote.proposal);
			if (vote) ranked[votings.length - vote?.priority] = proposal;
			else abstained.push(proposal);
		});

		if (ranked[0] !== undefined) ranked = ranked;
		else ranked = [];
		abstained = abstained;
	};

	const addToRanked = (proposal: proposal) => {
		unsaved = true;

		ranked.push(proposal);
		ranked = ranked;

		abstained = abstained.filter((prop) => prop !== proposal);
	};

	const addToAbstained = (proposal: proposal) => {
		unsaved = true;

		abstained.push(proposal);
		abstained = abstained;

		ranked = ranked.filter((prop) => prop !== proposal);
	};

	const moveDown = (index: number) => {
		unsaved = true;
		if (index === ranked.length - 1) return;
		//ES6 notation for swapping two elements in an array
		[ranked[index], ranked[index + 1]] = [ranked[index + 1], ranked[index]];
	};

	const moveUp = (index: number) => {
		unsaved = true;
		if (index === 0) return;
		//ES6 notation for swapping two elements in an array
		[ranked[index], ranked[index - 1]] = [ranked[index - 1], ranked[index]];
	};

	const doubleClick = (proposal: proposal, container: string) => {
		if (new Date(votingStartTime) > new Date()) return;
		unsaved = true;

		if (container === 'abstained') addToRanked(proposal);
		else addToAbstained(proposal);
	};

	const saveVotings = async () => {
		const proposals = document.querySelector('.container.ranked')?.children;
		let votes: number[] = [];

		if (!proposals) return;

		for (let i = 0; i < proposals?.length; i++) {
			votes.push(Number(proposals[i].id));
		}

		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/vote/update`,
			{
				votes
			}
		);

		status = statusMessageFormatter(res, json);
		//TODO replace with svelte store
		// const userId = (await fetchRequest('GET', 'user')).json.id;
		const userId = localStorage.getItem('userId')

		const isDelegate = (
			await fetchRequest('GET', `group/${$page.params.groupId}/users?user_id=${userId}`)
		).json.results[0].delegate;

		if (isDelegate)
			await fetchRequest(
				'POST',
				`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/vote/delegate/update`,
				{
					votes
				}
			);

		unsaved = false;
	};

	const getVotings = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/votes?limit=100`
		);
		votings = json.results;
	};

	const getDelegateId = async () => {
		const delegate_stuff = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegates?tag=${tag}`
		);

		console.log(delegate_stuff.json.results[0]);
		return 2;
	};

	const getDelegateVotings = async () => {
		const delegateId = await getDelegateId();
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/votes?delegates=True`
		);

		votings = json.results;
	};

	$: pollType === 3 && proposals && formatAllDates(proposals);
	// $: pollType === 3 && abstained && formatAllDates(abstained);
	// $: pollType === 3 && ranked && formatAllDates(ranked);
	// $: pollType === 3 && abstained && formatAllDates(abstained);

	const formatAllDates = (proposals: proposal[]) => {
		console.log(proposals, 'PROPS');
		proposals.map((proposal) => {
			proposal.title = `${formatDate(proposal.title)}`;
			proposal.description = formatDate(proposal.description).toString();
		});
	};
</script>

<div class={`poll border border-gray-500 lg:flex rounded ${unsaved && 'ring-2'}`}>
	{#if new Date(votingStartTime) <= new Date()}
		<div class="lg:w-1/2">
			{#if new Date(votingStartTime) <= new Date()}
				<div class="text-2xl p-6 select-none">{$_(pollType === 1 ? 'Rank' : 'Vote for')}</div>
				<ol class="container ranked lg:h-full">
					{#each ranked as proposal, i}
						<li
							id={`${proposal.id}`}
							class="proposal"
							on:dblclick={() => doubleClick(proposal, 'ranked')}
							on:click={() => (selected = proposal)}
						>
							<Proposal
								{...proposal}
								Class={`${selectedPage === 'You' && ''} ${
									(!checked && selectedPage !== 'Delegate') && 'cursor-move'
								}`}
							>
								<div class={`${(selectedPage === 'Delegate' || !checked) && 'invisible'}`}>
									<div on:click={() => addToAbstained(proposal)} class="cursor-pointer">
										<Fa icon={faMinus} />
									</div>
									{#if pollType !== 3}
										<div on:click={() => moveUp(i)} class="cursor-pointer">
											<Fa icon={faArrowUp} />
										</div>
										<div on:click={() => moveDown(i)} class="cursor-pointer">
											<Fa icon={faArrowDown} />
										</div>
									{/if}
								</div>
							</Proposal>
						</li>
					{/each}
				</ol>
			{/if}
		</div>
	{/if}
	<div class={`${new Date(votingStartTime) <= new Date() ? 'lg:w-1/2' : 'lg:w-full'}`}>
		<div class="text-2xl p-6 select-none">
			{$_(new Date(votingStartTime) <= new Date() ? 'Abstain' : 'Proposals')}
		</div>
		<ul class="container abstained lg:h-full">
			{#each abstained as proposal}
				<li
					id={`${proposal.id}`}
					class="proposal"
					on:dblclick={() => doubleClick(proposal, 'abstained')}
					on:click={() => (selected = proposal)}
				>
					<Proposal
						{...proposal}
						Class={`${selectedPage === 'You'} ${
							(!checked && selectedPage !== 'Delegate') && 'cursor-move'
						}`}
					>
						<div
							class={`${
								(selectedPage === 'Delegate' || new Date(votingStartTime) >= new Date() || !checked) &&
								'invisible'
							}`}
						>
							<div on:click={() => addToRanked(proposal)} class="cursor-pointer">
								<Fa icon={faPlus} />
							</div>
						</div>
					</Proposal>
				</li>
			{/each}
		</ul>
	</div>
</div>

<!-- TODO: Remove this and replace by allowing drag-drop
and buttons at the same time without a toggle both. -->
Enable buttons
<Toggle bind:checked/>

<StatusMessage bind:status />

{#if new Date(votingStartTime) <= new Date()}
	<Button action={saveVotings}
		>{(selectedPage === 'You' && $_('Save Votings')) ||
			(selectedPage === 'Delegate' && $_('Sync with Delegate'))}</Button
	>
{/if}

<style>
	.container {
		min-height: 100px;
	}
</style>
