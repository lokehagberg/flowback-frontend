<script lang="ts">
	import Pie from 'chart.js/auto';
	import { onMount } from 'svelte';

	export let labels = ['1'],
		votes = [1];

	let data = {
		labels,
		datasets: [
			{
				data: votes,
				backgroundColor: ['#0157BE', '#9333EA', '#93C5FD', '#D8B4FE']
			}
		],
		options: {
			responsive: false
		}
	};

	onMount(async () => {
		setupChart();
	});

	const setupChart = () => {
		new Pie(document.getElementById('pie-results') as HTMLCanvasElement, {
			type: 'pie',
			data,
			options: {
				responsive: false
			}
		});
	};
</script>

<div class=" m-auto">
	<canvas id="pie-results" />
</div>
