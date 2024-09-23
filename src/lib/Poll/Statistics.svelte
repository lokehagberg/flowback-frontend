<script lang="ts">
	import { Pie } from 'svelte-chartjs';

	export let labels = ['1'], votes = [1];

	let data = {
		labels: [],
		datasets: [
			{
				data: [],
				backgroundColor: ['#0157BE', '#9333EA', '#93C5FD', '#D8B4FE'],
			}
		],
		options: {
                responsive: false,
				onResize: () => {console.log("HI")}
            }
	};

	onMount(() => {
		setTimeout(() => {
			updateChart()
		}, 1000);
	});
	
	const updateChart = () => {
		labels.forEach(label => {
			chart.data.labels.push(label);
		});
	
		console.log(votes)
		votes.forEach(vote => {
			chart.data.datasets[0].data.push(vote);
		});
	
		chart.update()
	};

	let chart:any;

	import { Chart as ChartJS, Title, Tooltip, Legend, ArcElement, CategoryScale } from 'chart.js';
	import { onMount } from 'svelte';

	ChartJS.register(Title, Tooltip, Legend, ArcElement, CategoryScale);
</script>

<div class=" m-auto">
	<Pie bind:chart bind:data={data} options={{ responsive: true }} />
</div>