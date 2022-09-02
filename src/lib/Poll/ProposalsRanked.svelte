<script lang="ts">
	import { onMount } from 'svelte';
	import Proposal from './Proposal.svelte';

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

	//The Draggable package does not like reactive states, so we use slightly different code in this file
	onMount(async () => {
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

		sortable.on('drag:stop', (e: any) => {
		});
	});

	const addToRanked = (e: any) => {
		const proposal = e.path[2];
		document.querySelector('.container.ranked')?.appendChild(proposal);
	};

	const addToAbstained = (e: any) => {
		const proposal = e.path[2];
		document.querySelector('.container.abstained')?.appendChild(proposal);
	};

	const moveDown = (e: any) => {
		swap(e.path[3], e.path[3].nextSibling)
	};

	const moveUp = (e: any) => {
		swap(e.path[3], e.path[3].previousSibling)
	};

	const swap = (nodeA:HTMLObjectElement, nodeB:HTMLObjectElement) => {
		const parentA = nodeA?.parentNode;
		const siblingA = nodeA?.nextSibling === nodeB ? nodeA : nodeA.nextSibling;

		// Move `nodeA` to before the `nodeB`
		nodeB?.parentNode?.insertBefore(nodeA, nodeB);

		// Move `nodeB` to before the sibling of `nodeA`
		parentA?.insertBefore(nodeB, siblingA);
	}

</script>

<div class="poll border border-gray-700">
	<div class="text-2xl p-6 select-none">Rank</div>
	<ol class="container ranked" />
	<div class="text-2xl p-6 select-none">Abstain</div>

	<ul class="container abstained">
		{#each proposals as proposal}
			<li id={`${proposal.id}`}>
				<Proposal {...proposal}>
					<div class="abstained-plus" on:click={addToRanked}>+</div>
					<div class="ranking-arrows">
						<div on:click={addToAbstained}>-</div>
						<div on:click={moveUp}>^</div>
						<div on:click={moveDown}>v</div>
					</div>
				</Proposal>
			</li>
		{/each}
	</ul>
</div>

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
