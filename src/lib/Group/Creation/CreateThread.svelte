<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { _ } from 'svelte-i18n';
	import { goto } from '$app/navigation';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';

	let loading = false,
		title = '',
		poppup: poppup;

	const createThread = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.url.searchParams.get('id')}/thread/create`,
			{
				title
			}
		);
		if (!res.ok) {
			poppup = { message: "Couldn't create Thread", success: false };
		}
		if (res.ok) goto(`groups/${$page.url.searchParams.get('id')}/thread/${json}`);
	};
</script>

<div
	class="md:flex-row mt-8 gap-6 ml-8 mr-8 lg:w-[900px] bg-white rounded-sm dark:text-darkmodeText dark:bg-darkobject p-6"
>
	<h1 class="text-2xl">{$_('Create Thread')}</h1>
	<form on:submit|preventDefault={createThread} class="md:w-2/3 mt-2 w-full inline">
		<Loader bind:loading>
			<TextInput Class="w-full" label="Titel" required autofocus bind:value={title} />
			<Button Class="mt-2" type="submit">{$_('Submit')}</Button>
		</Loader>
	</form>
</div>
<Poppup bind:poppup />
