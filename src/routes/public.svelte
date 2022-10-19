<script>
	import Layout from '$lib/Generic/Layout.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
</script>

<Layout centering={true}> 
		<div class="bg-white rounded shadow p-8 mt-6">No polls currently here</div>
		<PollThumbnails Class="w-5/6 md:w-2/3 justify-center" />
</Layout>
