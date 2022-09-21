<script lang="ts">
	import TextInput from '../Generic/TextInput.svelte';
	import { fetchRequest } from '../FetchRequest'

	let username: string;
	let password: string;

	export let selectedPage: string;

	const logIn = async (e: any) => {
		e.preventDefault();
		const {json} = await fetchRequest("POST", "login", {username, password}, false)
			if (json.token) {
				localStorage.setItem('token', json.token);
				window.location.href = '/home';
			}
		}
	
</script>

<form class="p-6 gap-6 flex flex-col items-center" on:submit|preventDefault={logIn}>
	<TextInput label={'Email'} bind:value={username} required={true} />
	<TextInput label={'Password'} bind:value={password} type={'password'} required={true}/>

	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>

	<div class="mb-4 cursor-pointer hover:underline" on:click={() => (selectedPage = 'ForgotPassword')}>Forgot password?</div>
</form>
