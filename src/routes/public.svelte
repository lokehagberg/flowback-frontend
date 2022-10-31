<script>
	import Layout from '$lib/Generic/Layout.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import { _ } from 'svelte-i18n';
</script>

<Layout centering={true}>
	<PollThumbnails infoToGet="public" Class="mt-6 w-full sm:w-4/5 md:w-2/3 justify-center" />
</Layout>
