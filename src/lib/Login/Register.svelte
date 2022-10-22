<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import TextInput from '../Generic/TextInput.svelte';

	let username: string;
	let email: string;
	let status: StatusMessageInfo;

	export let selectedPage: string;

	async function registerAccount() {
		const { res, json } = await fetchRequest('POST', 'register', { username, email }, false);
		if (res.ok) {
			selectedPage = 'Verify';
			status = { message: 'Success', success: true };
		} else {
			if (json.detail) status = { message: json.detail[0], success: false };
			if (json.detail.email) status = { message: json.detail.email[0], success: false };
			if (json.detail.username) status = { message: json.detail.username[0], success: false };
		}
	}
</script>

<form class="p-6 gap-6 flex flex-col items-center" on:submit|preventDefault={registerAccount}>
	<TextInput label={'Username'} bind:value={username} required />
	<TextInput label={'Email'} bind:value={email} required />

	<StatusMessage bind:status />
	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>
</form>
