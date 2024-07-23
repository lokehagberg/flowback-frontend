<script lang="ts">
	import TextInput from '../Generic/TextInput.svelte';
	import { fetchRequest } from '../FetchRequest';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { _ } from 'svelte-i18n';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { goto } from '$app/navigation';
	// import { userInfo } from '$lib/Generic/GenericFunctions';

	let username: string,
		password: string,
		status: StatusMessageInfo,
		loading = false;

	export let selectedPage: string;

	const logIn = async () => {
		loading = true;
		const { json, res } = await fetchRequest('POST', 'login', { username, password }, false);
		loading = false;
		console.log('LOGIN');
		

		if (!res.ok) status = { message: json.detail.non_field_errors[0], success: false };
		else if (json?.token) {
			await localStorage.setItem('token', json.token);
			{
				const { json } = await fetchRequest('GET', 'user');
				localStorage.setItem('userId', json.id);
				localStorage.setItem('userName', json.username);
			}

			goto('/home');
		} else {
			status = statusMessageFormatter(res, json, 'There was a problem logging in');
		}
	};
</script>

<Loader bind:loading>
	<form class="p-6 gap-6 flex flex-col items-center" on:submit|preventDefault={logIn}>
		<TextInput label={'Email'} bind:value={username} required />
		<TextInput label={'Password'} bind:value={password} type={'password'} required />

		<input
			type="submit"
			value={$_('Login')}
			class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
		/>

		<StatusMessage bind:status />
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div
			class="mb-4 cursor-pointer hover:underline"
			on:click={() => (selectedPage = 'ForgotPassword')}
			on:keydown
		>
			{$_('Forgot password?')}
		</div>
	</form>
</Loader>
