<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import Loader from '$lib/Generic/Loader.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';

	import TextInput from '../Generic/TextInput.svelte';

	export let selectedPage: string = "", email: string = "";

	let loading = false;

	const sendCode = async () => {
		loading = true;
		const { res, json } = await fetchRequest('POST', 'forgot_password', { email }, false);
		loading = false;
		if (res.ok) selectedPage = 'GotMail';
		else ErrorHandlerStore.set(statusMessageFormatter(res, json));
	};
</script>

<Loader bind:loading>
	<form class="gap-6 p-6 flex flex-col items-center" on:submit|preventDefault={sendCode}>
		<TextInput label={'E-mail'} bind:value={email} required />
		 
		<Button type="submit" label="Send" />
	</form>
</Loader>
