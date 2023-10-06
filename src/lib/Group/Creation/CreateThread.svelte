<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
    import { page } from '$app/stores';

	let loading = false;

	const createThread = async () => {
		const { res, json } = await fetchRequest('POST', `group/${$page.url.searchParams.get('id')}/thread/create`, {
			title: 'WHaaat'
		});
	};
</script>

<div class="flex flex-col md:flex-row mt-8 gap-6 ml-8 mr-8 lg:w-[900px] dark:text-darkmodeText">
	<form on:submit|preventDefault={createThread} class="md:w-2/3">
		<Loader bind:loading>

            <Button type="submit">Submit</Button>
        </Loader>
	</form>
</div>
