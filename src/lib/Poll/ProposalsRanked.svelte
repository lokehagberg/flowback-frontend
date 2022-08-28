<script lang="ts">
	import Proposal from '$lib/Poll/Proposal.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faArrowRight } from '@fortawesome/free-solid-svg-icons/faArrowRight';
	import { faArrowDown } from '@fortawesome/free-solid-svg-icons/faArrowDown';
	import { faArrowUp } from '@fortawesome/free-solid-svg-icons/faArrowUp';
	import { faMinus } from '@fortawesome/free-solid-svg-icons/faMinus';
	import { onMount } from 'svelte';

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
			ut modi id iure minus amet. HJSHF jas jhjs hdjksah djkxwhua jdbca jkb loremjkb loremjkb loremjkb loremjkb loremjkb`,
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
	let abstained: Proposal[] = [...proposals];

	//Removes the proposal from its current container (be it abstain or rank) and move it to the other one
	const switchProposalContainer = (proposalId: number, proposalPosition: number) => {
		//It checks if the proposal is in ranked already. Ranked is checked first since it will the most often have the fewest members
		//and won't meaningfully slow down the search if the proposal is in abstained.
		//It then removes it from it's own container and tacks it to the new one.
		//TODO (if needed): Generalise to any number of containers
		const proposalInRanked = ranked.find((proposal) => proposal.id === proposalId);

		if (proposalInRanked !== undefined) {
			abstained.push(proposalInRanked);
			abstained = abstained;

			ranked.splice(proposalPosition, 1);
			ranked = ranked;
			return;
		}

		const proposalInAbstained = abstained.find((proposal) => proposal.id === proposalId);

		if (proposalInAbstained !== undefined) {
			ranked.push(proposalInAbstained);
			ranked = ranked;

			abstained.splice(proposalPosition, 1);
			abstained = abstained;
		}
	};

	//When a proposal is in the ranking container, swap two proposals with eachother
	const swapProposalRanking = (proposalIndex1: number, proposalIndex2: number) => {
		const b = ranked[proposalIndex1];
		ranked[proposalIndex1] = ranked[proposalIndex2];
		ranked[proposalIndex2] = b;
		ranked = ranked;
	};

	onMount(async () => {
		const { Sortable } = await import('@shopify/draggable');

		new Sortable(document.querySelectorAll('#container'), {
			draggable: 'li'
		});

		
	});
</script>

<div class="poll border border-gray-700">
	<div style="grid-column: 1 / 2; grid-row: 1 / 2" class="text-2xl p-6">Abstain</div>
	<div style="grid-column: 2 / 3; grid-row: 1 / 2" class="text-2xl p-6">Rank</div>
	<ul style="grid-column: 1 / 2" id="container">
		{#each abstained as proposal, i}
			<li style={`grid-column: 1 / 2; grid-row:${i + 2} / ${i + 2 + 1}`}>
				<Proposal title={proposal.title} description={proposal.description}>
					<div
						slot="right-icons"
						class="cursor-pointer"
						on:click={() => switchProposalContainer(proposal.id, i)}
					>
						<Fa icon={faArrowRight} />
					</div>
				</Proposal>
			</li>
		{/each}
	</ul>
	<ul style="grid-column: 2 / 3" id="container">
		{#each ranked as proposal, i}
			<li style={`grid-column: 2 / 3; grid-row:${i + 2} / ${i + 2 + 1}`}>
				<Proposal title={proposal.title} description={proposal.description}>
					<div slot="right-icons" class="cursor-pointer">
						<div on:click={() => swapProposalRanking(i, i - 1)}><Fa icon={faArrowUp} /></div>
						<div on:click={() => swapProposalRanking(i, i + 1)}><Fa icon={faArrowDown} /></div>
						<div on:click={() => switchProposalContainer(proposal.id, i)}>
							<Fa icon={faMinus} />
						</div>
					</div>
				</Proposal>
			</li>
		{/each}
	</ul>
	<ul style="grid-column: 3 / 4">
		{#each ranked as proposal, i}
			<li style={`grid-column: 3 / 4; grid-row: ${i + 2} / ${i + 2 + 1}; text-align:center`}>
				{i + 1}
			</li>
		{/each}
	</ul>
</div>

<style>
	.poll {
		display: grid;
		grid-template-columns: 8fr 8fr 1fr;
		align-items: center;
		column-gap: 2rem;
	}
</style>
