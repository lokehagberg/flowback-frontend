<script lang="ts">
	import { Pie } from 'svelte-chartjs';
	import { Chart as ChartJS, Title, Tooltip, Legend, ArcElement, CategoryScale } from 'chart.js';
	import { onMount } from 'svelte';

	ChartJS.register(Title, Tooltip, Legend, CategoryScale, ArcElement);

	export let votes: number[] = [1],
		labels: string[] = [''];

	let data = {
		labels,
		datasets: [
			{
				label: 'Results',
				fill: true,
				//TODO: Make sure to make these colors editable when we're adding stylesheets
				backgroundColor: ['#0157BE', '#9333EA', '#93C5FD', '#D8B4FE'],
				borderColor: ['#FFFFFF'],
				data: votes
			}
		]
	};

	console.log(data, 'datadfsasfzfdsdasfstadatfsdgadtadata');

	onMount(() => {
		data = {
			labels,
			datasets: [
				{
					label: 'Results',
					fill: true,
					//TODO: Make sure to make these colors editable when we're adding stylesheets
					backgroundColor: ['#0157BE', '#9333EA', '#93C5FD', '#D8B4FE'],
					borderColor: ['#FFFFFF'],
					data: votes
				}
			]
		};
	});
</script>

<Pie {data} options={{ responsive: true }} />
