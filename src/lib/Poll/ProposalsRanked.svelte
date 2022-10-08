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

	//
	export let votings: votings[];
	let proposals: proposal[] = [];
	let ranked: proposal[] = [];
	let abstained: proposal[] = [];

	let unsaved = false;

	/*The Draggable package does not like reactive states, 
	so we use non-reactive code in this file.*/
	onMount(async () => {
		setUpSortable();
		await getProposals();
		setOrdering();
	});

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

		sortable.on('sortable:stop', (e: any) => {

			const element = e.data.dragEvent.data.originalSource;
			// const index = Array.from(element.parentElement.children).indexOf(element);
			const index = e.data.newIndex

			console.log(e, element, index)
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
			if (vote) ranked[proposals.length - vote?.priority] = proposal;
			else abstained.push(proposal);
		});

		console.log(ranked, abstained, votings);

		// clearContainer('abstained');
		// clearContainer('ranked');

		ranked = ranked;
		abstained = abstained;
	};

	const clearContainer = (container: 'ranked' | 'abstained') => {
		const htmlContainer = document.querySelector(`.${container}.ranked`);

		if (htmlContainer)
			while (htmlContainer.firstChild) {
				htmlContainer.removeChild(htmlContainer.firstChild);
			}
	};

	const addToRanked = (e: any) => {
		const proposal = getProposal(e);
		document.querySelector('.container.ranked')?.appendChild(proposal.parentElement);
	};

	const addToAbstained = (e: any) => {
		const proposal = getProposal(e);
		document.querySelector('.container.abstained')?.appendChild(proposal.parentElement);
	};

	/*
	Alot of the "extra complexity" (it's not that complex) 
	in this code is due to Font Awesome's 
	icon structure being several divs deep.
	Instead of directly selecting a div with a plus element in it, 
	a person's click can instead go to slightly 
	different layers in the icon structure.
	To remedy it, there's a for loop on the path in the 
	DOM on the div that was clicked
	that will terminate when it finds the 
	proposal div and then swap/move it.
	*/
	const moveDown = (e: any) => {
		const element = e.path.find((element: HTMLObjectElement) =>
			element.classList.contains('proposal')
		);
		swap(element.parentElement, element.parentElement.nextSibling);
	};

	const moveUp = (e: any) => {
		const element = e.path.find((element: HTMLObjectElement) =>
			element.classList.contains('proposal')
		);
		swap(element.parentElement, element.parentElement.previousSibling);
	};

	const doubleClick = (e: any) => {
		const proposal = getProposal(e);

		if (proposal.parentNode.parentNode.classList.contains('abstained')) addToRanked(e);
		else addToAbstained(e);
	};

	const swap = (nodeA: HTMLObjectElement, nodeB: HTMLObjectElement) => {
		const parentA = nodeA?.parentNode;
		const siblingA = nodeA?.nextSibling === nodeB ? nodeA : nodeA.nextSibling;

		// Move `nodeA` to before the `nodeB`
		nodeB?.parentNode?.insertBefore(nodeA, nodeB);

		// Move `nodeB` to before the sibling of `nodeA`
		parentA?.insertBefore(nodeB, siblingA);
	};

	const getProposal = (e: any) => {
		return e.path.find((element: HTMLObjectElement) => element.classList.contains('proposal'));
	};

	const saveVotings = async () => {
		const proposals = document.querySelector('.container.ranked')?.children;
		let votes: number[] = [];

		if (!proposals) return;

		for (let i = 0; i < proposals?.length; i++) {
			votes.push(Number(proposals[i].id));
		}

		await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/vote/update`,
			{
				votes
			}
		);

		await getVotings();
		setOrdering();
	};

	const getVotings = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/votes?limit=100`
		);
		votings = json.results;
	};
</script>

<div class={`poll border border-gray-500 lg:flex rounded ${unsaved && 'ring-2'}`}>
	<div class="lg:w-1/2">
		<div class="text-2xl p-6 select-none">Rank</div>
		<ol class="container ranked lg:h-full" />
	</div>
	<div class="lg:w-1/2">
		<div class="text-2xl p-6 select-none">Abstain</div>
		<ul class="container abstained lg:h-full">
			{#each proposals as proposal}
				<li id={`${proposal.id}`} class="proposal" on:dblclick={doubleClick}>
					<Proposal {...proposal}>
						<div class="abstained-plus">
							<div on:click={addToRanked} class="cursor-pointer"><Fa icon={faPlus} /></div>
						</div>
						<div class="ranking-arrows">
							<div on:click={addToAbstained} class="cursor-pointer"><Fa icon={faMinus} /></div>
							<div on:click={moveUp} class="cursor-pointer"><Fa icon={faArrowUp} /></div>
							<div on:click={moveDown} class="cursor-pointer"><Fa icon={faArrowDown} /></div>
						</div>
					</Proposal>
				</li>
			{/each}
		</ul>
	</div>
</div>
<ButtonPrimary action={saveVotings}>Save votings</ButtonPrimary>

<style>
	.abstained > li .ranking-arrows {
		display: none;
	}

	.ranked > li .abstained-plus {
		display: none;
	}

	.container {
		min-height: 100px;
	}
</style>
