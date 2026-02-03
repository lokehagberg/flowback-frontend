<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import Loader from '$lib/Generic/Loader.svelte';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import { _ } from 'svelte-i18n';
	import TextInput from '../Generic/TextInput.svelte';
	import { mailStore } from './stores';
	import TermsOfService from './TermsOfService.svelte';
	import { env } from '$env/dynamic/public';

	let email: string,
		loading = false,
		acceptedToS = false,
		usernameError: string = '';

	export let selectedPage: string;

	async function registerAccount() {
		if (!acceptedToS) {
			ErrorHandlerStore.set({
				message: 'You must accept terms of service to register',
				success: false
			});
			return;
		}

		if (usernameError) {
			ErrorHandlerStore.set({ message: usernameError, success: false });
			return;
		}

		loading = true;
		const { res, json } = await fetchRequest('POST', 'register', { email }, false);
		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({
				message:
					(json?.detail?.email && json?.detail?.email[0]) ??
					(json?.detail && json?.detail[0]) ??
					json ??
					'Something went wrong',
				success: false
			});
			return;
		}

		mailStore.set(email);
		ErrorHandlerStore.set({ message: 'Email Sent', success: true });

		if (!(env.PUBLIC_EMAIL_REGISTRATION === 'FALSE')) selectedPage = 'GotMail';
		else selectedPage = 'Verify';
	}
</script>

<Loader bind:loading>
	<form class="p-6 gap-6 flex flex-col items-center" on:submit|preventDefault={registerAccount}>
		<TextInput label={'Email'} bind:value={email} required />
		<TermsOfService />
		<RadioButtons
			label="Do you accept terms and conditions?"
			centering={true}
			bind:Yes={acceptedToS}
		/>
		<Button type="submit">
			{$_('Send')}
		</Button>
	</form>
</Loader>
