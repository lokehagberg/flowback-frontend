<script>
	import Layout from '$lib/Generic/Layout.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import { _ } from 'svelte-i18n';
</script>

<Layout centered>
	<PollThumbnails infoToGet="public" Class="mt-6 sm:w-full md:w-4/5 md:max-w-[720px] justify-center" />
</Layout>
