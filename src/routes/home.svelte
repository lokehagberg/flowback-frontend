<script>
	import { fetchRequest } from '$lib/FetchRequest';
	import Layout from '$lib/Generic/Layout.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	onMount(async () => {
		const {res, json}  = await fetchRequest('GET', 'group/invites')
	})
</script>

<Layout centering={true}> 
		<div class="bg-white rounded shadow p-8 mt-6">{$_("No polls currently here, join a group to see more")}</div>
		<!-- <PollThumbnails Class="w-5/6 md:w-2/3 justify-center" /> -->
</Layout>
