<script lang="ts">
	import '../app.css';
	import { initializeLocalization } from '$lib/Localization/i18n';
	import Header from '$lib/Header/Header.svelte';
	import { beforeNavigate, goto, onNavigate } from '$app/navigation';
	import {
		getGroupUserInfo,
		getUserInfo,
		userInfo,
		getPermissions
	} from '$lib/Generic/GenericFunctions';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { GroupUser } from '$lib/Group/interface';
	import type { Permission } from '$lib/Group/Permissions/interface';
	import NewChat from '$lib/Chat/NewChat/Chat.svelte';
	import OldChat from '$lib/Chat/Chat.svelte';
	import { _ } from 'svelte-i18n';
	import { env } from '$env/dynamic/public';
	import { fetchRequest } from '$lib/FetchRequest';
	import { workGroupsStore } from '$lib/Group/WorkingGroups/interface';
	import LogBackInModal from '$lib/Generic/LogBackInModal.svelte';

	// Chat configuration flags
	const ENABLE_OLD_CHAT = false;  // Set to false to disable old chat
	const ENABLE_NEW_CHAT = true;  // Set to false to disable new chat

	export const prerender = true;

	let showUI = false,
		scrolledY = '',
		openLoginModal = false;

	const updateUserInfo = async () => {
		let userNeedsUpdate = false;
		let groupId = Number($page.params.groupId);

		userInfo.update((user) => {
			if (!user || !user.user || ($page.params.groupId !== undefined && groupId !== user.groupId)) {
				userNeedsUpdate = true;
			}
			return user;
		});

		if (userNeedsUpdate) {
			const userData = await getUserInfo();
			let groupUserData: GroupUser, permissions: Permission;
			if (groupId) {
				groupUserData = await getGroupUserInfo(groupId);
				if (groupUserData?.permission_id)
					permissions = await getPermissions(groupId, groupUserData.permission_id);
			}

			userInfo.update((user) => {
				if (!user) user = { user: userData };
				else user.user = userData;

				if (!user.groupId && groupId) user.groupId = groupId;
				if (user && !user.groupuser && groupId) user.groupuser = groupUserData;
				if (user && !user.permission && groupId) user.permission = permissions;

				if (!groupId) {
					user.groupuser = undefined;
					user.groupId = undefined;
					user.permission = undefined;
				}
				return user;
			});
		}
	};

	const shouldShowUI = () => {
		let pathname = window?.location?.pathname;

		if (pathname === '/login') return false;
		else if (pathname === '/') return false;
		else if (
			!window.localStorage.getItem('token') ||
			!window.localStorage.getItem('userId')
		)
			return false;

		return true;
	};

	//TODO: Avoid code duplication and introduce group stores for storing group data.
	const getGrouplist = async () => {
		const { res, json } = await fetchRequest('GET', 'group/list');
		if (!res.ok) return;
		else return json.results;
	};

	const redirect = async () => {
		const groups = await getGrouplist();
		const relativePath = new URL(location.href).pathname;

		let pathname = window?.location?.pathname;

		if (window.localStorage.getItem('token') === undefined && relativePath !== '/login')
			goto('/login');
		else if (
			//For one group flowback, if no group has been setup, redirect to create group.
			env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' &&
			relativePath !== '/creategroup' &&
			groups.length === 0
		)
			goto('/creategroup');
		else if (pathname === '/') goto('/home');

		const sessionExpiration = window.localStorage.getItem('sessionExpirationTime');
		if (
			sessionExpiration &&
			relativePath !== '/login' &&
			sessionExpiration < new Date().getTime().toString()
		) {
			localStorage.removeItem('token');
			goto('/login');
		}
	};

	const getWorkingGroupList = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/list?limit=100&order_by=name_asc`
		);

		if (!res.ok) return;

		workGroupsStore.set(json.results);
	};

	const checkSessionExpiration = () => {
		const sessionExpiration = window.localStorage.getItem('sessionExpirationTime');
		if (!sessionExpiration) return;

		const expirationTime = Number(sessionExpiration);
		const currentTime = new Date().getTime();

		// Check if it will expire within next hour
		if (expirationTime > currentTime && expirationTime - currentTime < 3600000) {
			openLoginModal = true;
		}
	};

	beforeNavigate(() => {
		scrolledY = $page.params.pollId;
	});

	onNavigate(() => {
		getWorkingGroupList();

		showUI = shouldShowUI();
		redirect();
		if (showUI) updateUserInfo();
		setTimeout(() => {
			const html = document.getElementById(`poll-thumbnail-${scrolledY}`);
			html?.scrollIntoView();
		}, 200);

		checkSessionExpiration();
	});

	//Initialize Translation, which should happen before any lifecycle hooks.
	initializeLocalization();

	onMount(() => {
		getWorkingGroupList();
		showUI = shouldShowUI();
		redirect();
		if (showUI) updateUserInfo();
		setTimeout(() => {
			const html = document.getElementById(`poll-thumbnail-${scrolledY}`);
			html?.scrollIntoView();
		}, 200);

		checkSessionExpiration();
	});
</script>

<main class="">
	{#if showUI}
		{#if ENABLE_NEW_CHAT}
			<NewChat />
		{/if}
		{#if ENABLE_OLD_CHAT}
			<OldChat />
		{/if}
		<Header />
	{/if}

	<slot />
</main>

<div id="mobile-support">
	{$_('No support for mobile devices yet, try Flowback on a non-mobile device')}
</div>

<LogBackInModal bind:open={openLoginModal} />

<style>
	#mobile-support {
		display: none;
	}

	#chat-button {
		background: white;
		padding: 1rem;
		border-radius: 50%;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
		transition: all 0.2s;
	}

	#chat-button:hover {
		transform: scale(1.05);
		box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
	}

	#chat-button:active {
		transform: scale(0.95);
	}

	@media (max-width: 716px) {
		main {
			display: none !important;
		}

		#mobile-support {
			display: block !important;
		}
	}
</style>
