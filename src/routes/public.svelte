<script>
	import Layout from '$lib/Generic/Layout.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import { _ } from 'svelte-i18n';
</script>

<Layout centering={true}>
	<PollThumbnails infoToGet="public" Class="mt-6 sm:w-full md:w-4/5 xl:max-w-[800px]  justify-center" />
</Layout>
