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
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';

	export let votings: votings[];
	export let selectedPage: 'You' | 'Delegate';
	let proposals: proposal[] = [];
	let ranked: proposal[] = [];
	export let abstained: proposal[] = [];

	export let tag: number;

	let unsaved = false;
	let status: number;

	$: selectedPage && setUpVotings();
	$: console.log(abstained);

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
		console.log(ranked, 'PRANKEDS');
	};

	const getProposals = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposals?limit=100`
		);
		proposals = json.results;
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
			e.cancel();
		});

		sortable.on('sortable:stop', async (e: any) => {
			console.log(e, 'STOPPED');
		});

		sortable.on('sortable:sorted', async (e: any) => {
			unsaved = true;

			console.log(e, 'SORTED');

			// const element: HTMLElement = e.data.dragEvent.data.originalSource;
			// const index: number = e.data.newIndex;
			// const parent = e.data.newContainer.className.includes('ranked') ? 'ranked' : 'abstained';
			// element.classList.add('remove-after-placed');

			// const proposal = proposals.find((proposal) => Number(element.id) === proposal.id);

			// if (!proposal) return;

			// if (parent === 'ranked') {
			// 	// const oldRanked = ranked;
			// 	// ranked = [];

			// 	// const ee = document.querySelector('.container.ranked');

			// 	// var first = ee?.firstElementChild;

			// 	// while (first) {
			// 	// 	console.log(first)
			// 	// 	first.remove();
			// 	// 	first = ee?.firstElementChild;
			// 	// }

			// 	await waitForElm('.remove-after-placed');

			// 	ranked.splice(index, 0, proposal);
			// 	ranked = ranked;

			// 	// sortable.destroy()
			// 	// console.log(document.querySelector("."))
			// 	// console.log(elementLater.parentNode?.removeChild(document.querySelector(".remove-after-placed")))
			// } else {
			// 	abstained.push(proposal);
			// 	abstained = abstained;
			// }

			// const elementLater = await waitForElm('.remove-after-placed');
			// elementLater.parentNode?.removeChild(elementLater);
			// setTimeout(() => {
			// 	element.parentNode?.removeChild(element)
			// }, 1000)
			// console.log(element.parentNode)
			// console.log(e.data.dragEvent)
			// element.parentNode?.removeChild(element)
			// console.log(e.data.dragEvent.data.originalSource.parent.removeChild(e.data.dragEvent.data.originalSource))
		});

		function waitForElm(selector: string): Promise<Element> {
			return new Promise((resolve) => {
				const obj = document.querySelector(selector);
				if (obj) {
					return resolve(obj);
				}

				const observer = new MutationObserver((mutations) => {
					const objLater = document.querySelector(selector);
					if (objLater) {
						resolve(objLater);
						observer.disconnect();
					}
				});

				observer.observe(document.body, {
					childList: true,
					subtree: true
				});
			});
		}

		sortable.on('sortable:start', (e: any) => {
			if (selectedPage === 'Delegate') {
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

		ranked = new Array(votings.length);
		abstained = [];

		proposals.forEach((proposal) => {
			const vote = votings.find((vote) => proposal.id === vote.proposal);
			if (vote) ranked[votings.length - vote?.priority] = proposal;
			else abstained.push(proposal);
		});

		console.log(ranked, abstained, votings);

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

		const { res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/vote/update`,
			{
				votes
			}
		);

		//TODO replace with svelte store
		const userId = (await fetchRequest('GET', 'user')).json.id;

		const isDelegate = (
			await fetchRequest('GET', `group/${$page.params.groupId}/users?user_id=${userId}`)
		).json.results[0].delegate;

		if (isDelegate)
			fetchRequest(
				'POST',
				`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/vote/delegate/update`,
				{
					votes
				}
			);

		unsaved = false;
		status = res.status;
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
	}

	const getDelegateVotings = async () => {
		const delegateId = await getDelegateId()

		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/votes?delegate_user_id=${delegateId}`
		);

		votings = json.results;
	};
</script>

<div class={`poll border border-gray-500 lg:flex rounded ${unsaved && 'ring-2'}`}>
	<div class="lg:w-1/2">
		<div class="text-2xl p-6 select-none">Rank</div>
		<ol class="container ranked lg:h-full">
			{#each ranked as proposal, i}
				<li
					id={`${proposal.id}`}
					class="proposal"
					on:dblclick={() => doubleClick(proposal, 'ranked')}
				>
					<!-- for when drag and drop works cursor-move -->
					<Proposal {...proposal} Class={`${selectedPage === 'You' && ''}`}>
						<div class={`${selectedPage === 'Delegate' && 'invisible'}`}>
							<div on:click={() => addToAbstained(proposal)} class="cursor-pointer">
								<Fa icon={faMinus} />
							</div>
							<div on:click={() => moveUp(i)} class="cursor-pointer"><Fa icon={faArrowUp} /></div>
							<div on:click={() => moveDown(i)} class="cursor-pointer">
								<Fa icon={faArrowDown} />
							</div>
						</div>
					</Proposal>
				</li>
			{/each}
		</ol>
	</div>
	<div class="lg:w-1/2">
		<div class="text-2xl p-6 select-none">Abstain</div>
		<ul class="container abstained lg:h-full">
			{#each abstained as proposal}
				<li
					id={`${proposal.id}`}
					class="proposal"
					on:dblclick={() => doubleClick(proposal, 'abstained')}
				>
					<!-- for when drag and drop works cursor-move -->
					<Proposal {...proposal} Class={`${selectedPage === 'You' && ''}`}>
						<div class={`${selectedPage === 'Delegate' && 'invisible'}`}>
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
<StatusMessage bind:status />
<ButtonPrimary action={saveVotings}
	>{(selectedPage === 'You' && 'Save Votings') ||
		(selectedPage === 'Delegate' && 'Sync with Delegate')}</ButtonPrimary
>

<style>
	.container {
		min-height: 100px;
	}
</style>
