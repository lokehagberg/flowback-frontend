<script lang="ts">
import { fetchRequest } from '$lib/FetchRequest';

	import TextInput from '../Generic/TextInput.svelte';

	let username: string;
	let email: string;
	export let selectedPage: string;

	async function registerAccount(e: any) {
		e.preventDefault();
		const response = await fetchRequest("POST", "register", {username, email}, false)
		if (response) selectedPage = 'Verify';
	}
</script>

<form class="p-6 gap-6 flex flex-col items-center" on:submit|preventDefault={registerAccount}>
	<TextInput label={'Username'} bind:value={username} />
	<TextInput label={'Email'} bind:value={email} />

	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>
</form>
