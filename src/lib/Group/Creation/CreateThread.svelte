<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
    import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';

	let loading = false, title = ""

	const createThread = async () => {
		const { res, json } = await fetchRequest('POST', `group/${$page.url.searchParams.get('id')}/thread/create`, {
			title
		});
	};
</script>

<div class="md:flex-row mt-8 gap-6 ml-8 mr-8 lg:w-[900px] dark:text-darkmodeText bg-darkobject p-6">
	<h1>Create Thread</h1>
	<form on:submit|preventDefault={createThread} class="md:w-2/3 mt-2 w-full inline">
		<Loader bind:loading>
			<TextInput Class="w-full" label="Titel" required autofocus bind:value={title}/>
            <Button Class="mt-2" type="submit">Submit</Button>
        </Loader>
	</form>
</div>
