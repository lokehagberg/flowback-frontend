<script lang="ts">
	import TextInput from '../Generic/TextInput.svelte';
	import { fetchRequest } from '../FetchRequest';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { _ } from 'svelte-i18n';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	// import { userInfo } from '$lib/Generic/GenericFunctions';

	let username: string;
	let password: string;
	let status: StatusMessageInfo;

	export let selectedPage: string;

	const logIn = async (e: any) => {
		const { json, res } = await fetchRequest('POST', 'login', { username, password }, false);

		console.log(json)
		if (!res.ok) {
			status =
				res.status === 400
					? { message: 'Username or password is wrong', success: false }
					: { message: 'Server error', success: false };

			return;
		}

		if (json.token) {
			status = { message: 'Successfully logged in', success: true };
			localStorage.setItem('token', json.token);
			// localStorage.setItem('userInfo', json)

			{
				const { json } = await fetchRequest('GET', 'user');
				// userInfo.set(json);
			}

			window.location.href = '/home';
		}
	};
</script>

<form class="p-6 gap-6 flex flex-col items-center" on:submit|preventDefault={logIn}>
	
	<TextInput label={'Email'} bind:value={username} required={true} />
	<TextInput label={'Password'} bind:value={password} type={'password'} required={true} />
	
	<input
	type="submit"
	class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>
	
	<StatusMessage bind:status />
	<div
		class="mb-4 cursor-pointer hover:underline"
		on:click={() => (selectedPage = 'ForgotPassword')}
	>
		{$_('Forgot password?')}
	</div>
</form>
