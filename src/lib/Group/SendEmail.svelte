<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { page } from '$app/stores';
	import TextArea from '$lib/Generic/TextArea.svelte';

	let title: string, message: string;

	const sendEmail = async () => {
		await fetchRequest('POST', `groups/${$page.params.groupId}/mail`);
	};
</script>

<div class="bg-white p-6 text-xl rounded shadow p-6">
	<form on:submit|preventDefault={sendEmail} class="flex flex-col gap-4">
		<TextInput required label="Title" bind:value={title} />
		<TextArea required label="Message" bind:value={message} />
		<ButtonPrimary type="submit" Class="mt-4" />
	</form>
</div>
