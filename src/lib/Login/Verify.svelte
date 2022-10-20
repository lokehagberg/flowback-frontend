<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';

	import TextInput from '../Generic/TextInput.svelte';

	let verification_code: string;
	let password: string;
	let status: StatusMessageInfo;
	export let selectedPage: string;

	async function verifyAccount() {
		const { res, json } = await fetchRequest(
			'POST',
			'register/verify',
			{ verification_code, password },
			false
		);
		if (res.ok) {
			selectedPage = 'Login';
			status = { message: 'Success', success: true };
		} else {
			if (json.detail) status = { message: json.detail[0], success: false };
			if (json.detail.verification_code)
				status = { message: "Wrong verification code", success: false };
			if (json.detail.non_field_errors) status = { message: json.detail.non_field_errors[0], success: false };
		}
	}
</script>

<form class="gap-6 p-6 flex flex-col items-center" on:submit|preventDefault={verifyAccount}>
	<TextInput label={'Verification Code'} bind:value={verification_code} required={true} />
	<TextInput label={'Password'} bind:value={password} type={'password'} required={true} />

	<StatusMessage bind:status />
	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>
</form>
