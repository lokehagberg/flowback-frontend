<script lang="ts">
	import { onMount } from 'svelte';
	import Proposal from './Proposal.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faArrowRight } from '@fortawesome/free-solid-svg-icons/faArrowRight';
	import { faArrowDown } from '@fortawesome/free-solid-svg-icons/faArrowDown';
	import { faArrowUp } from '@fortawesome/free-solid-svg-icons/faArrowUp';
	import { faMinus } from '@fortawesome/free-solid-svg-icons/faMinus';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
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

		sortable.on('drag:stop', (e: any) => {});
	});

	//Alot of the extra complexity in this code is due to Font Awesome's icon structure being several divs deep.
	//Instead of directly selecting the proposal, a person's click can go to slightly different layers in the icon structure.
	//To remedy it, there's a for loop on the path that will terminate when it finds the proposal div and then swap/move it.
	const addToRanked = (e: any) => {
		const proposal = e.path.find((element:HTMLObjectElement) => element.classList.contains("proposal"))
		document.querySelector('.container.ranked')?.appendChild(proposal.parentElement);
	};

	const addToAbstained = (e: any) => {
		const proposal = e.path.find((element:HTMLObjectElement) => element.classList.contains("proposal"))
		document.querySelector('.container.abstained')?.appendChild(proposal.parentElement);
	};

	const moveDown = (e: any) => {
		const element = e.path.find((element:HTMLObjectElement) => element.classList.contains("proposal"))
		swap(element.parentElement, element.parentElement.nextSibling);
	};

	const moveUp = (e: any) => {
		const element = e.path.find((element:HTMLObjectElement) => element.classList.contains("proposal"))
		swap(element.parentElement, element.parentElement.previousSibling);
	};

	const swap = (nodeA: HTMLObjectElement, nodeB: HTMLObjectElement) => {
		const parentA = nodeA?.parentNode;
		const siblingA = nodeA?.nextSibling === nodeB ? nodeA : nodeA.nextSibling;

		// Move `nodeA` to before the `nodeB`
		nodeB?.parentNode?.insertBefore(nodeA, nodeB);

		// Move `nodeB` to before the sibling of `nodeA`
		parentA?.insertBefore(nodeB, siblingA);
	};
</script>

<div class="poll border border-gray-700">
	<div class="text-2xl p-6 select-none">Rank</div>
	<ol class="container ranked" />
	<div class="text-2xl p-6 select-none">Abstain</div>

	<ul class="container abstained">
		{#each proposals as proposal}
			<li id={`${proposal.id}`} class="proposal">
				<Proposal {...proposal}>
					<div class="abstained-plus">
						<div on:click={addToRanked}><Fa icon={faPlus} /></div>
					</div>
					<div class="ranking-arrows">
						<div on:click={addToAbstained}><Fa icon={faMinus} /></div>
						<div on:click={moveUp}><Fa icon={faArrowUp} /></div>
						<div on:click={moveDown}><Fa icon={faArrowDown} /></div>
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
