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
		console.log(proposalId, proposalPosition)
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
		if (proposalIndex2 === -1 || proposalIndex2 >= ranked.length) return;

		const b = ranked[proposalIndex1];
		ranked[proposalIndex1] = ranked[proposalIndex2];
		ranked[proposalIndex2] = b;
		ranked = ranked;
	};

	const reRenderContainers = (e:any) => {
		console.log("EVENT", e)
		// e.data.originalSource.remove()
		// e.data.source.remove()
		switchProposalContainer(1, 0)
		// const abstainedContainer = document.querySelector('#container-abstained');
		// if (abstainedContainer === null) return;

		// const proposalsAbstained = Array.from(Array(abstainedContainer.children)[0]);
		// let idsAbstained = proposalsAbstained.map((element) => {
		// 	return element.id;
		// });

		// const rankedContainer = document.querySelector('#container-ranked');
		// if (rankedContainer === null) return;

		// const proposalsRanked = Array.from(Array(rankedContainer.children)[0]);
		// // console.log(proposalsRanked);
		// let idsRanked = proposalsRanked.map((element) => {
		// 	return element.id;
		// });

		// const idThatWasMoved = idsAbstained.filter((id) => idsRanked.includes(id))[0];

		// if (idsAbstained[idsAbstained.length - 1] === '')
		// 	idsAbstained = idsAbstained.filter((id) => id !== idThatWasMoved && id !== '');
		// else idsRanked = idsRanked.filter((id) => id !== idThatWasMoved && id !== '');

		// abstained = proposals.filter((proposal) => idsAbstained.includes(proposal.id.toString()));
		// ranked = proposals.filter((proposal) => idsRanked.includes(proposal.id.toString()));

		// console.log(idsAbstained, idsRanked, ranked);
		// const rankedContainer2 = document.querySelector('#container-ranked');
		// if (rankedContainer2 === null) return;
		// console.log(Array(rankedContainer2.children)[0]);
	};

	onMount(async () => {
		const { Sortable } = await import('@shopify/draggable');

		const containers = [
			document.querySelector('#container-abstained'),
			document.querySelector('#container-ranked')
		];

		const sortable = new Sortable(containers, {
			draggable: 'li',
			classes: {
				mirror: ['draggable--over', 'bg-red-200', 'bg-opacity-25']
			}
		});

		sortable.on('drag:stop', reRenderContainers);
	});
</script>

<div class="poll border border-gray-700">
	<div style="grid-column: 1 / 2; grid-row: 1 / 2" class="text-2xl p-6 select-none">Abstain</div>
	<div style="grid-column: 2 / 3; grid-row: 1 / 2" class="text-2xl p-6 select-none">Rank</div>
	<ul style="grid-column: 1 / 2" id="container-abstained" class="h-full">
		{#each abstained as proposal, i}
			<li
				style={`grid-column: 1 / 2; grid-row:${i + 2} / ${i + 2 + 1}`}
				id={proposal.id.toString()}
			>
				<Proposal {...proposal}>
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
	<ol style="grid-column: 2 / 3" id="container-ranked" class="h-full">
		{#each ranked as proposal, i}
			<li
				style={`grid-column: 2 / 3; grid-row:${i + 2} / ${i + 2 + 1}`}
				id={proposal.id.toString()}
			>
				<Proposal {...proposal}>
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
	</ol>
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
