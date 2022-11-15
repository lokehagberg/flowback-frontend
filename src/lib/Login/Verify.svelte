<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Loader from '$lib/Generic/Loader.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { _ } from 'svelte-i18n';
	import TextInput from '../Generic/TextInput.svelte';
	import { mailStore } from './stores';

	let verification_code: string;
	let password: string;
	let status: StatusMessageInfo;
	let loading = false;

	async function verifyAccount() {
		loading = true;
		const { res, json } = await fetchRequest(
			'POST',
			'register/verify',
			{ verification_code, password },
			false
		);
		if (res.ok) {
			// Getting username which is stored in the store from Register.svelte
			let email = '';
			mailStore.subscribe((mail) => (email = mail));
			const { json, res } = await fetchRequest(
				'POST',
				'login',
				{ username: email, password },
				false
			);

			loading = false;

			if (res.ok && json.token) {
				status = { message: 'Success', success: true };
				localStorage.setItem('token', json.token);
				window.location.href = '/home';
			} else status = { message: 'Account was created but was unable to sign in', success: true };
		} else {
			loading = false;
			if (json.detail) status = { message: json.detail[0], success: false };
			if (json.detail.verification_code)
				status = { message: 'Wrong verification code', success: false };
			if (json.detail.non_field_errors)
				status = { message: json.detail.non_field_errors[0], success: false };
		}
	}
</script>

<Loader bind:loading>
	<form class="gap-6 p-6 flex flex-col items-center" on:submit|preventDefault={verifyAccount}>
		<TextInput label={'Verification Code'} bind:value={verification_code} required />
		<TextInput label={'Password'} bind:value={password} type={'password'} required />

		<StatusMessage bind:status />
		<ButtonPrimary type="submit" >
			{$_('Send')}
		</ButtonPrimary>
	</form>
</Loader>
