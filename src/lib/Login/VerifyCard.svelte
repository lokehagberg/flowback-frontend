<script lang="ts">
	import TextInput from '../Generic/TextInput.svelte';

	let verification_code: string;
	let password: string;
	export let selectedPage: string;

	async function verifyAccount(e: any) {
		e.preventDefault();
		const response = await fetch('https://v2.flowback.org/register/verify', {
			method: 'POST',
			headers: {
				Accept: 'application/json',
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				verification_code,
				password
			})
		});
		console.log(response);
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
