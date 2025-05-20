<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Loader from '$lib/Generic/Loader.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { _ } from 'svelte-i18n';
	import TextInput from '../Generic/TextInput.svelte';
	import { mailStore } from './stores';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import { goto } from '$app/navigation';
	import { env } from '$env/dynamic/public';
	import { becomeMemberOfGroup } from '$lib/Blockchain_v1_Ethereum/javascript/rightToVote';
	import { onMount } from 'svelte';

	let verification_code: string,
		password: string,
		status: StatusMessageInfo,
		loading = false,
		acceptedEmailNotifications = false;

		onMount(() => {
			const urlParams = new URLSearchParams(window.location.search);
			verification_code = urlParams.get('verification_code') || '';
			const email = urlParams.get('email') || '';
			mailStore.set(email);
		});

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
				//Done with account registration, redirect
				status = { message: 'Success', success: true };
				localStorage.setItem('token', json.token);

				{
					const { res, json } = await fetchRequest('POST', 'user/update', {
						email_notifications: acceptedEmailNotifications
					});
				}

				//For one group flowback, immediately join the list of groups
				if (env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE') {
					const joinGroup = async () => {
						const { res } = await fetchRequest('POST', `group/1/join`, { to: 1 });
						if (res.ok) {
							if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE')
								becomeMemberOfGroup(group.blockchain_id);

							goto('/home');
						}
					};
					//If multi-group flowback, just go to the list of groups
				} else goto('/groups');
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
		<span>{$_(`We have sent a verification code to the provided email. Don't forget to check your junk mail!`)}</span>
		<TextInput label={'Verification Code'} bind:value={verification_code} required />
		<TextInput label={'Choose a Password'} bind:value={password} type={'password'} required />
		<RadioButtons
			label="Do you want to receive Email Notifications?"
			centering={true}
			bind:Yes={acceptedEmailNotifications}
		/>
		<StatusMessage bind:status />
		<Button type="submit">
			{$_('Send')}
		</Button>
	</form>
</Loader>
