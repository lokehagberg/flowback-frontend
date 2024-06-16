<script lang="ts">
	import '../app.css';
	import { initializeLocalization } from '$lib/Localization/i18n';
	import Header from '$lib/Header/Header.svelte';
	import { onNavigate } from '$app/navigation';
	import { getUserInfo, userInfo } from '$lib/Generic/GenericFunctions';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';

	initializeLocalization();
	export const prerender = true;

	onNavigate(async () => {
		let userNeedsUpdate = false;

		userInfo.update((user) => {
			if (
				!user ||
				!user.user ||
				($page.params.groupId !== undefined && Number($page.params.groupId) !== user.groupId)
			) {
				userNeedsUpdate = true;
			}
			return user;
		});

		if (userNeedsUpdate) {
			const userData = await getUserInfo();
			userInfo.update((user) => {
				if (!user) user = { user: userData };
				else user.user = userData;
				return user;
			});
		}
	});

	onMount(() => {
		userInfo.subscribe((info) => console.log('LE INFO:', info));
	});
</script>

<main class="h-[100wh]">
	<Header />
	<slot />
</main>
