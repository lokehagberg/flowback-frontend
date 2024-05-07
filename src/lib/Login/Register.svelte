<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Loader from '$lib/Generic/Loader.svelte';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { _ } from 'svelte-i18n';
	import TextInput from '../Generic/TextInput.svelte';
	import { mailStore } from './stores';
	import TermsOfService from './TermsOfService.svelte';

	let username: string;
	let email: string;
	let status: StatusMessageInfo;
	let loading = false;
	let acceptedToS = false;

	export let selectedPage: string;

	async function registerAccount() {
		if (!acceptedToS) {
			status = { message: 'You must accept terms of service to register', success: false };
			return;
		}
		loading = true;
		const { res, json } = await fetchRequest('POST', 'register', { username, email }, false);
		loading = false;
		if (res.ok) {
			mailStore.set(email);
			status = {message: "Successfully registered", success:true};
			selectedPage = 'Verify';
		} else status = {message: json.detail[0], success:false};
	}
</script>

<Loader bind:loading>
	<form class="p-6 gap-6 flex flex-col items-center" on:submit|preventDefault={registerAccount}>
		<TextInput label={'Username'} bind:value={username} required />
		<TextInput label={'Email'} bind:value={email} required />
		<TermsOfService />
		<RadioButtons
			label="Do you accept terms and conditions?"
			centering={true}
			bind:Yes={acceptedToS}
		/>
		<StatusMessage bind:status />
		<Button type="submit">
			{$_('Send')}
		</Button>
	</form>
</Loader>
