<script lang="ts">
	import Proposal from '../lib/Poll/Proposal.svelte';
	import Header from '$lib/Header/Header.svelte';

	interface Proposal {
		title:string,
		description:string,
		id:number
	}

	let abstained: Proposal[] = [
		{
			title: 'Nuclear Option',
			description: `Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet.`,
			id:1
		},
		{
			title: 'Geothermal Power explosion',
			description: `Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet.`,
			id:2
		},
		{
			title: 'Evil Pollen',
			description: `Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quia repudiandae nesciunt ipsam quo
			earum, nemo error necessitatibus minima eligendi voluptatem vel? Praesentium dicta reiciendis
			ut modi id iure minus amet.`,
			id:3
		}
	];

	let ranked: Proposal[] = [

	];

	const moveProposal = (proposalId1:number, proposalId2:number) => {



	}
	const handleRankChange = (proposal1:Proposal, proposal2:Proposal) => {

	}
</script>

<Header />
<div class="p-10 m-10 bg-gray-200">
	<h1>Destroy Lithuania</h1>
	<div class="poll border border-gray-700">
		<div style="grid-column: 1 / 2; grid-row: 1 / 2">Abstain</div>
		<div style="grid-column: 2 / 3; grid-row: 1 / 2">Rank</div>
		{#each abstained as proposal, i}
			<div style={`grid-column: 1 / 2; grid-row:${i + 2} / ${i + 2 + 1}`}>
				<Proposal title={proposal.title} description={proposal.description} />
			</div>
		{/each}
		{#each ranked as proposal, i}
			<div style={`grid-column: 2 / 3; grid-row:${i + 2} / ${i + 2 + 1}`}>
				<Proposal title={proposal.title} description={proposal.description} />
			</div>
		{/each}
		{#each ranked as num, i}
			<div style={`grid-column: 3 / 4; grid-row: ${i + 2} / ${i + 2 + 1}; text-align:center`}>
				{i + 1}
			</div>
		{/each}
	</div>
</div>

<style>
	.poll {
		display: grid;
		grid-template-columns: 8fr 8fr 1fr;

		align-items: center;
	}
</style>
