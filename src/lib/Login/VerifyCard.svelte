<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';

	import TextInput from '../Generic/TextInput.svelte';

	let verification_code: string;
	let password: string;
	export let selectedPage: string;

	async function verifyAccount(e: any) {
		e.preventDefault();
		const response = await fetchRequest('POST', 'register/verify', { verification_code, password });
		selectedPage = 'Login';
	}
</script>

<form class="flex flex-col items-center" on:submit|preventDefault={verifyAccount}>
	<TextInput label={'Verification Code'} bind:value={verification_code} />
	<TextInput label={'Password'} bind:value={password} type={'password'} />

	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>
</form>
