<script lang="ts">
	import TextInput from '../Generic/TextInput.svelte';
	import { fetchRequest } from '../FetchRequest';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { _ } from 'svelte-i18n';
	// import { userInfo } from '$lib/Generic/GenericFunctions';

	let username: string;
	let password: string;
	let status: { message: string | null; success: boolean };

	export let selectedPage: string;

	const logIn = async (e: any) => {
		const { json, res } = await fetchRequest('POST', 'login', { username, password }, false);

		if (!res.ok) {
			status =
				res.status === 500
					? { message: 'Server error', success: false }
					: { message: 'Username or password is wrong', success: false };

			return;
		}

		if (json.token) {			
			status = { message: 'Successfully logged in', success: true };
			localStorage.setItem('token', json.token);
			
			{
				const { json } = await fetchRequest('GET', 'user');
				// userInfo.set(json);
			}
			
			window.location.href = '/home';
		}
	};
</script>

<form class="p-6 gap-6 flex flex-col items-center" on:submit|preventDefault={logIn}>
	<StatusMessage bind:status />

	<TextInput label={'Email'} bind:value={username} required={true} />
	<TextInput label={'Password'} bind:value={password} type={'password'} required={true} />

	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>

	<div
		class="mb-4 cursor-pointer hover:underline"
		on:click={() => (selectedPage = 'ForgotPassword')}
	>
		{$_('Forgot password?')}
	</div>
</form>
