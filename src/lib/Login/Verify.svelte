<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';

	import TextInput from '../Generic/TextInput.svelte';

	let verification_code: string;
	let password: string;
	export let selectedPage: string;

	async function verifyAccount() {
		const { res } = await fetchRequest(
			'POST',
			'register/verify',
			{ verification_code, password },
			false
		);
		if (res.ok) selectedPage = 'Login';
	}
</script>

<form class="gap-6 p-6 flex flex-col items-center" on:submit|preventDefault={verifyAccount}>
	<TextInput label={'Verification Code'} bind:value={verification_code} required={true} />
	<TextInput label={'Password'} bind:value={password} type={'password'} required={true} />

	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>
</form>
