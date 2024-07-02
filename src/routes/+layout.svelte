<script lang="ts">
	import '../app.css';
	import { initializeLocalization } from '$lib/Localization/i18n';
	import Header from '$lib/Header/Header.svelte';
	import { onNavigate } from '$app/navigation';
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

	export const prerender = true;

	let showUI = false;

	initializeLocalization();

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
				if (groupUserData.permission_id)
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

	onNavigate(() => {
		updateUserInfo();
		showUI = window?.location?.pathname !== '/login';
	});

	onMount(() => {
		updateUserInfo();
		showUI = window?.location?.pathname !== '/login' && window.localStorage.getItem('token') !== undefined;
	});
</script>

<main class="h-[100wh]">
	{#if showUI}
		<Chat />
		<Header />
	{/if}

	<slot />
</main>
