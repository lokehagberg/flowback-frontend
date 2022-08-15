<script lang="ts">
import Header from "$lib/Header/Header.svelte";

	const months = [
		'Jan',
		'Feb',
		'Mar',
		'Apr',
		'May',
		'Jun',
		'Jul',
		'Aug',
		'Sep',
		'Oct',
		'Nov',
		'Dec'
	];

	const currentDate = new Date();
	let month = currentDate.getMonth();
	let year = currentDate.getFullYear();
	let selectedDay = currentDate.getDate();
	let polls = [];
	let loading = false;
	let pollList = [];
</script>
<Header />

<div on:click={() => year -= 1}>{"<"}</div>
{year}
<div on:click={() => year += 1}>{">"}</div>

<div on:click={() => month -= 1}>{"<"}</div>
{months[month]}
<div on:click={() => month += 1}>{">"}</div>


