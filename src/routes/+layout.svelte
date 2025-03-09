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
	import Chat from '$lib/Chat/Chat.svelte';
	import { _ } from 'svelte-i18n';

	export const prerender = true;

	let showUI = false,
		scrolledY = '';

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
			window.localStorage.getItem('token') === undefined ||
			window.localStorage.getItem('userId') === undefined
		)
			return false;

		return true;
	};

	const redirect = () => {
		let pathname = window?.location?.pathname;

		if (window.localStorage.getItem('token') === undefined) goto('/login');
		else if (pathname === '/') goto('/home');

		const sessionExpiration = window.localStorage.getItem('sessionExpirationTime');
		if (sessionExpiration)
			if (sessionExpiration && sessionExpiration < new Date().getTime().toString()) {
				localStorage.removeItem('token');
				// 	goto('/login')
			}
	};

	beforeNavigate(() => {
		scrolledY = $page.params.pollId;
	});

	onNavigate(() => {
		showUI = shouldShowUI();
		redirect();
		if (showUI) updateUserInfo();
		setTimeout(() => {
			const html = document.getElementById(`poll-thumbnail-${scrolledY}`);
			html?.scrollIntoView();
		}, 200);
	});

	//Initialize Translation, which should happen before any lifecycle hooks.
	initializeLocalization();

	onMount(() => {
		showUI = shouldShowUI();
		redirect();
		if (showUI) updateUserInfo();
		setTimeout(() => {
			const html = document.getElementById(`poll-thumbnail-${scrolledY}`);
			html?.scrollIntoView();
		}, 200);
	});
</script>

<main class="">
	{#if showUI}
		<Chat />
		<Header />
	{/if}

	<slot />
</main>
<div id="mobile-support">{$_('No support for mobile devices yet')}</div>

<style>
	#mobile-support {
		display: none;
	}

	@media (max-width: 500px) {
		main {
			display: none !important;
		}

		#mobile-support {
			display: block !important;
		}
	}
</style>
