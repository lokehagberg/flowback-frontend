<script lang="ts">
	import '../app.css';
	import { initializeLocalization } from '$lib/Localization/i18n';
	import Header from '$lib/Header/Header.svelte';
	import { beforeNavigate, goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import {
		groupUserPermissionStore,
		groupUserStore
	} from '$lib/Group/interface';
	import Chat from '$lib/Chat/Chat.svelte';
	import { _ } from 'svelte-i18n';
	import { env } from '$env/dynamic/public';
	import { fetchRequest } from '$lib/FetchRequest';
	import LogBackInModal from '$lib/Generic/LogBackInModal.svelte';
	import { userStore } from '$lib/User/interfaces';
	import ErrorHandler from '$lib/Generic/ErrorHandler.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { setUserGroupPermissionInfo } from '$lib/Group/functions';
	import { workgroupStore } from '$lib/Group/Kanban/Kanban';

	let showUI = false,
		scrolledY = '',
		openLoginModal = false,
		isBrowser = false,
		errorhandler: any;

	const shouldShowUI = () => {
		let pathname = window?.location?.pathname;

		if (pathname.includes('/login')) return false;
		else if (pathname === '/') return false;
		else if (window.localStorage.getItem('token') === undefined) return false;

		return true;
	};

	//TODO: Avoid code duplication and introduce group stores for storing group data.
	const getGrouplist = async () => {
		const { res, json } = await fetchRequest('GET', 'group/list');

		if (!res.ok) return;
		else return json?.results;
	};

	const redirect = async () => {
		if (!isBrowser) return;

		const relativePath = window.location.pathname;

		let pathname = window?.location?.pathname;

		const sessionExpirationTime = window.localStorage.getItem(
			'sessionExpirationTime'
		);
		if (
			sessionExpirationTime &&
			!relativePath.includes('/login') &&
			sessionExpirationTime < new Date().getTime().toString()
		) {
			localStorage.removeItem('token');
			goto('/login');
		} else if (
			!window.localStorage.getItem('token') &&
			!relativePath.includes('/login')
		)
			goto('/login');
		else if (
			//For one group flowback, if no group has been setup, redirect to create group.
			env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' &&
			relativePath !== '/creategroup'
		) {
			const groups = await getGrouplist();
			if (groups.length === 0) goto('/creategroup');
		} else if (pathname === '/') goto('/home');
	};

	const getWorkingGroupList = async () => {
		if (!$page.params.groupId) return;
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/list?limit=100&order_by=name_asc`
		);

		if (!res.ok) return;

		workgroupStore.set(json?.results);
	};

	const checkSessionExpiration = () => {
		const sessionExpiration = window.localStorage.getItem(
			'sessionExpirationTime'
		);
		if (!sessionExpiration) return;

		const expirationTime = Number(sessionExpiration);
		const currentTime = new Date().getTime();

		// Check if it will expire within next hour
		if (
			expirationTime > currentTime &&
			expirationTime - currentTime < 3600000
		) {
			openLoginModal = true;
		}
	};

	const setUserGroupInfo = async () => {
		if (!$userStore?.id) return;

		if (
			!$page.params.groupId &&
			!(window.location.pathname === '/createpoll')
		) {
			groupUserStore.set(null);
			return;
		}

		// Fix for /createpoll page
		let search = new URLSearchParams(window.location.search).get('id');

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId ?? search}/users?user_id=${$userStore?.id}`
		);

		if (!res.ok || json?.results.length === 0) {
			groupUserStore.set(null);
			goto('/groups');
			return;
		}

		groupUserStore.set(json?.results[0]);
	};

	const setUserInfo = async () => {
		const { json } = await fetchRequest('GET', 'user');
		userStore.set(json);
	};

	beforeNavigate(() => {
		scrolledY = $page.params.pollId ?? '';
	});

	$: if ($page.url.pathname && isBrowser) onPathChange();

	const onPathChange = async () => {
		redirect();
		getWorkingGroupList();
		showUI = shouldShowUI();

		setTimeout(() => {
			document.body.scrollIntoView();
		}, 200);

		checkSessionExpiration();
		await setUserInfo();
		await setUserGroupInfo();
		groupUserPermissionStore.set(
			await setUserGroupPermissionInfo($groupUserStore)
		);
	};

	//Initialize Translation, which should happen before any lifecycle hooks.
	initializeLocalization();

	onMount(async () => {
		await setUserInfo();
		await setUserGroupInfo();
		groupUserPermissionStore.set(
			await setUserGroupPermissionInfo($groupUserStore)
		);
		isBrowser = true;
		getWorkingGroupList();
		showUI = shouldShowUI();
		redirect();

		setTimeout(() => {
			document.body.scrollIntoView();
		}, 200);

		checkSessionExpiration();

		ErrorHandlerStore.subscribe((_errorhandler) => {
			if (!_errorhandler) return;
			if (_errorhandler.message === '') return;
			if (!errorhandler) return;

			errorhandler.addPopup({
				message: _errorhandler.message,
				success: _errorhandler.success
			});
		});

		document.body.classList.remove('invisible');
		document.body.style.visibility = 'visible';
	});
</script>

<main class="min-h-[100vh]">
	{#if showUI}
		<Chat />
		<Header />
	{/if}

	<slot />
</main>

<LogBackInModal bind:open={openLoginModal} />

<ErrorHandler bind:this={errorhandler} />
