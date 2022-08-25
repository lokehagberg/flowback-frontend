<script lang="ts">
	import Proposal from '$lib/Poll/Proposal.svelte';
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faArrowRight } from '@fortawesome/free-solid-svg-icons/faArrowRight';
	import { faArrowDown } from '@fortawesome/free-solid-svg-icons/faArrowDown';
	import { faArrowUp } from '@fortawesome/free-solid-svg-icons/faArrowUp';
	interface Proposal {
		title: string;
		description: string;
		id: number;
	}

	let proposals: Proposal[] = [
		{
			title: 'Nuclear Option',
			description: `Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet. HJSHF jas jhjs hdjksah djkxwhua jdbca jkb`,
			id: 1
		},
		{
			title: 'Geothermal Power explosion',
			description: `Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet.`,
			id: 2
		},
		{
			title: 'Evil Pollen',
			description: `Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet.`,
			id: 3
		}
	];

	let ranked: Proposal[] = [];
	let abstained: Proposal[] = proposals;
	let rankedId: number[] = [];

	//Removes the proposal from its current container (be it abstain or rank) and move it to the other one
	//Potential speedup can be done by using a dictionary with id's and rank placement
	const switchProposalContainer = (proposalId1: number, proposalPosition:number) => {
		const rankedIdIndex = rankedId.findIndex((proposal) => proposal === proposalId1);
		const proposal = proposals.find((proposal) => proposal.id === proposalId1);

		if (rankedIdIndex === -1 && proposal) {
			ranked.push(proposal);
			ranked = ranked;

			abstained.splice(proposalPosition, 1)
			abstained = abstained
		} else {
			rankedId.splice(rankedIdIndex, 1);
		}
	};

	//When a proposal is in the ranking container, swap two proposals with eachother
	const swapProposalRanking = (proposalIndex1: number, proposalIndex2: number) => {
		const b = ranked[proposalIndex1];
		ranked[proposalIndex1] = ranked[proposalIndex2];
		ranked[proposalIndex2] = b;
		ranked = ranked;
	};
</script>

<div class="poll border border-gray-700">
	<div style="grid-column: 1 / 2; grid-row: 1 / 2">Abstain</div>
	<div style="grid-column: 2 / 3; grid-row: 1 / 2">Rank</div>
	{#each abstained as proposal, i}
		<div style={`grid-column: 1 / 2; grid-row:${i + 2} / ${i + 2 + 1}`}>
			<Proposal title={proposal.title} description={proposal.description}>
				<div
					slot="right-icons"
					class="cursor-pointer"
					on:click={() => switchProposalContainer(proposal.id, i)}
				>
					<Fa icon={faArrowRight} />
				</div>
			</Proposal>
		</div>
	{/each}
	{#each ranked as proposal, i}
		<div style={`grid-column: 2 / 3; grid-row:${i + 2} / ${i + 2 + 1}`}>
			<Proposal title={proposal.title} description={proposal.description}>
				<div slot="right-icons" class="cursor-pointer">
					<div on:click={() => swapProposalRanking(i, i - 1)}><Fa icon={faArrowUp} /></div>
					<div on:click={() => swapProposalRanking(i, i + 1)}><Fa icon={faArrowDown} /></div>
				</div>
			</Proposal>
		</div>
	{/each}
	{#each ranked as proposal, i}
		<div style={`grid-column: 3 / 4; grid-row: ${i + 2} / ${i + 2 + 1}; text-align:center`}>
			{i + 1}
		</div>
	{/each}
</div>

<style>
	.poll {
		display: grid;
		grid-template-columns: 8fr 8fr 1fr;
		align-items: center;
		column-gap:2rem;
	}
</style>
