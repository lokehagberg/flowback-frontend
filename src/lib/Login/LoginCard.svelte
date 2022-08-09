<script lang="ts">
	import TextInput from '../Generic/TextInput.svelte';
	import { fetchRequest } from '../FetchRequest'

	let username: string;
	let password: string;

	export let selectedPage: string;

	async function logIn(e: any) {
		e.preventDefault();
		const response = await fetchRequest("POST", "login", {username, password})

		response.json().then((data) => {
			if (data.token) {
				localStorage.setItem('token', data.token);
				window.location.href = '/home';
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
