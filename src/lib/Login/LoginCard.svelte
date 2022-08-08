<script lang="ts">
	import TextInput from '../Generic/TextInput.svelte';

	let username: string;
	let password: string;

	export let selectedPage: string;

	async function logIn(e: any) {
		e.preventDefault();
		const response = await fetch('https://v2.flowback.org/login', {
			method: 'POST',
			headers: {
				Accept: 'application/json',
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				username,
				password
			})
		});

		response.json().then((data) => {
			if (data.token) {
				localStorage.setItem('token', data.token);
				window.location.href = '/';
			}
		});
	}
</script>

<form class="flex flex-col items-center" on:submit|preventDefault={logIn}>
	<TextInput label={'Email'} bind:value={username} />
	<TextInput label={'Password'} bind:value={password} type={'password'} />

	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>

	<div class="mb-4 cursor-pointer hover:underline" on:click={() => (selectedPage = 'ForgotPassword')}>Forgor 💀 password?</div>
</form>
