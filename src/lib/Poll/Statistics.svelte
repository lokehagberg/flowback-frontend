<script lang="ts">
	import { Pie } from 'svelte-chartjs';
	import { Chart as ChartJS, Title, Tooltip, Legend, ArcElement, CategoryScale } from 'chart.js';

	ChartJS.register(Title, Tooltip, Legend, CategoryScale, ArcElement);

	export let votes: number[] = [1],
		labels: string[] = [''];

	const data = {
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

	console.log(data, 'datadfsafsfsfsassfzfdsdaddsssfddatfsdgadtadata');

	// onMount(() => {
	// 	data = {
	// 		labels,
	// 		datasets: [
	// 			{
	// 				label: 'Results',
	// 				fill: true,
	// 				//TODO: Make sure to make these colors editable when we're adding stylesheets
	// 				backgroundColor: ['#0157BE', '#9333EA', '#93C5FD', '#D8B4FE'],
	// 				borderColor: ['#FFFFFF'],
	// 				data: votes
	// 			}
	// 		]
	// 	};
	// });
</script>

<Pie {data} options={{ responsive: true }} />


<!-- <script>
	import { Line } from 'svelte-chartjs'
	import { Chart as ChartJS } from 'chart.js';
	ChartJS.register(Line)
  
  </script>
  
  
  <Line data={{labels:['hi', '2', '4'], datasets: [
	{
		label:"haw",
		backgroundColor: "#444444",
		fill:-1,
		data:[1,2,3]
	}
  ]}} /> -->


<!-- <script>
	import { Line } from 'svelte-chartjs'
  </script>
  
  <Line data={{labels:['hi'], datasets: [
	{
		data:[1,2,3]
	}
  ]}} /> -->


<!-- 
  <script>
	import { Pie } from 'svelte-chartjs';
	import { data } from './data.js';
  
	import {
	  Chart as ChartJS,
	  Title,
	  Tooltip,
	  Legend,
	  ArcElement,
	  CategoryScale,
	} from 'chart.js';
  
	ChartJS.register(Title, Tooltip, Legend, ArcElement, CategoryScale);
  </script>
  
  <Pie {data} options={{ responsive: true }} />
   -->