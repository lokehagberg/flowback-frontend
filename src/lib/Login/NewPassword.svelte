<script lang="ts">
import { fetchRequest } from '$lib/FetchRequest';

	import TextInput from '$lib/Generic/TextInput.svelte';
	export let selectedPage: string;
	let password: string;
	let verification_code: string;

    async function registerAccount() {
		const {res} = await fetchRequest("POST", "forgot_password/verify", {verification_code, password}, false )
		if (res.ok) selectedPage = 'Verify';
	}
</script>

<form class="gap-6 p-6 flex flex-col items-center" on:submit|preventDefault={registerAccount}>
	<TextInput label={'New Password'} bind:value={password} type="password" required={true}/>
	<TextInput label={'Verification Code'} bind:value={verification_code} required={true} />

	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>
</form>
