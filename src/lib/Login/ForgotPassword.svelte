<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Loader from '$lib/Generic/Loader.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import TextInput from '../Generic/TextInput.svelte';

	export let selectedPage: string;
	let email: string;
	let status:StatusMessageInfo;
	let loading = false;

	const sendCode = async () => {
		loading = true
		const { res, json } = await fetchRequest('POST', 'forgot_password', { email }, false);
		loading = false
		if (res.ok) selectedPage = 'NewPassword';
		else{
			if (json.detail) status = {message:json.detail[0], success:false}
			if (json.detail.email) status = {message:json.detail.email[0], success:false}
		}
	};
</script>

<Loader bind:loading>
<form class="gap-6 p-6 flex flex-col items-center" on:submit|preventDefault={sendCode}>
	<TextInput label={'E-mail'} bind:value={email} required/>

	<StatusMessage bind:status/>
	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
		label="Skicka"
	/>
</form>
</Loader>
