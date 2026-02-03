<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { env } from '$env/dynamic/public';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { userStore } from '$lib/User/interfaces';

	let password: string,
		password2: string,
		verification_code: string,
		loading = false;

	async function verifyAccount() {
		if (env.PUBLIC_EMAIL_REGISTRATION === 'TRUE')
			verification_code = $page.url.searchParams.get('verification_code') ?? '';

		if (password !== password2) {
			ErrorHandlerStore.set({ message: 'Passwords do not match', success: false });
			return;
		}

		loading = true;
		const { res, json } = await fetchRequest(
			'POST',
			'forgot_password/verify',
			{ verification_code, password },
			false
		);

		if (!res.ok) {
			if (
				json?.detail?.verification_code ||
				json?.detail[0] === 'Not found.' ||
				json?.detail[0] === 'Verification code has already been used.'
			)
				ErrorHandlerStore.set({ message: 'Wrong verification code', success: false });
			else if (json?.detail?.non_field_errors)
				ErrorHandlerStore.set({ message: json?.detail?.non_field_errors[0], success: false });
			else if (json?.detail?.username)
				ErrorHandlerStore.set({ message: json?.detail?.username[0], success: false });
			else if (json?.detail[0] === 'Email already registered')
				ErrorHandlerStore.set({ message: json?.detail[0], success: false });
			else ErrorHandlerStore.set({ message: 'Something went wrong', success: false });

			return;
		}

		//Done with account registration, redirect
		ErrorHandlerStore.set({ message: 'Success', success: true });

		localStorage.setItem('token', json.token);

		{
			const { json } = await fetchRequest('GET', 'user');
			userStore.set(json);
		}

		loading = false;

		//For one group flowback, immediately join the single group
		if (env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE') {
			const { res } = await fetchRequest('POST', `group/1/join`, { to: 1 });
			if (!res.ok) {
				ErrorHandlerStore.set({
					message: 'Account was created but failed to join group',
					success: false
				});
			}
		}

		goto('/home');
	}
</script>

<form class="gap-6 p-6 flex flex-col items-center" on:submit|preventDefault={verifyAccount}>
	<TextInput label={'New Password'} bind:value={password} type="password" required />
	<TextInput label={'Confirm Password'} bind:value={password2} type="password" required />
	{#if !(env.PUBLIC_EMAIL_REGISTRATION === 'TRUE')}
		<TextInput label={'Verification Code'} bind:value={verification_code} required />
	{/if}

	<Button type="submit" label="Send" />
</form>
