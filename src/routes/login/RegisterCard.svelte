<script lang="ts">
	import TextInput from './TextInput.svelte';

	import './index.css';

	let username: string;
	let email: string;

	async function registerAccount(e: any) {
		
		e.preventDefault();
		const response = await fetch('https://v2.flowback.org/register', {
			method: 'POST',
			headers: {
				Accept: 'application/json',
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				username,
				email
			})
		});
	}
</script>

<form class="flex flex-col items-center" on:submit|preventDefault={registerAccount}>
	<TextInput label={'Username'} bind:value={username} />
	<TextInput label={'Email'} bind:value={email} />

	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>
</form>