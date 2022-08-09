<script>
	import { getRequest } from '$lib/FetchRequest';
	import PollThumbnail from '$lib/Poll/PollThumbnail.svelte';
	import { onMount } from 'svelte';
	import Header from '../lib/Header/Header.svelte';

	onMount(async () => {
		const response = await getRequest('users', localStorage.getItem('token') || '');
		console.log(response.json());
	});
</script>

<Header />

<div class="flex flex-col items-center">
	<div class="w-3/4">
		<div>Flow</div>
		<PollThumbnail />
	</div>
</div>
