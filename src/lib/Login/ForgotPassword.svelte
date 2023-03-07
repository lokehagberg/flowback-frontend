<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Loader from '$lib/Generic/Loader.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import TextInput from '../Generic/TextInput.svelte';

	export let selectedPage: string;
	export let email: string;
	let status: StatusMessageInfo;
	let loading = false;

	const sendCode = async () => {
		loading = true;
		const { res, json } = await fetchRequest('POST', 'forgot_password', { email }, false);
		loading = false;
		if (res.ok) selectedPage = 'NewPassword';
		else status = statusMessageFormatter(res, json);
	};
</script>

<Loader bind:loading>
	<form class="gap-6 p-6 flex flex-col items-center" on:submit|preventDefault={sendCode}>
		<TextInput label={'E-mail'} bind:value={email} required />
		<StatusMessage bind:status />
		<Button type="submit" label="Send" />
	</form>
</Loader>
