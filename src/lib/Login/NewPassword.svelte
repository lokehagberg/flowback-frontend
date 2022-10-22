<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';

	import TextInput from '$lib/Generic/TextInput.svelte';
	export let selectedPage: string;
	let password: string;
	let verification_code: string;
	let status: StatusMessageInfo;

	const registerAccount = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			'forgot_password/verify',
			{ verification_code, password },
			false
		);
		if (res.ok) selectedPage = 'Verify';
		else {
			if (json.detail) status = { message: json.detail[0], success: false };
			if (json.detail.verification_code)
				status = { message: json.detail.verification_code[0], success: false };
			if (json.detail.password) status = { message: json.detail.password[0], success: false };
		}
	};
</script>

<form class="gap-6 p-6 flex flex-col items-center" on:submit|preventDefault={registerAccount}>
	<TextInput label={'New Password'} bind:value={password} type="password" required />
	<TextInput label={'Verification Code'} bind:value={verification_code} required />

	<StatusMessage bind:status />
	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>
</form>
