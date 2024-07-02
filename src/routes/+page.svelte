<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import {initializeLocalization} from '$lib/Localization/i18n'
	import { goto } from '$app/navigation';

	let status: StatusMessageInfo, initializedLocale = false;

	const logIn = async (username: string, password: string) => {
		const { res, json } = await fetchRequest(
			'POST',
			`login`,
			{
				username,
				password
			},
			false
		);
		if (json?.token) {
			status = statusMessageFormatter(res, json, 'Successfully logged in');
			await localStorage.setItem('token', json.token);
			{
				const { json } = await fetchRequest('GET', 'user');
				localStorage.setItem('userId', json.id);
				localStorage.setItem('userName', json.username);
			}

			goto('/home');
		} else {
			status = statusMessageFormatter(res, json, 'Problems');
		}
	};

	const setUpLocale = () => {
		if (!initializedLocale)
		initializeLocalization();
		else initializedLocale = true;
	}

	onMount(async () => {
		let params = new URLSearchParams(window.location.search);
		const username = params.getAll('username')[0];
		const password = params.getAll('password')[0];
		if (username && password) logIn(username, password);
	});
</script>

<svelte:head>
	<title>{$_('Welcome to Flowback')}</title>
</svelte:head>
<StatusMessage bind:status />