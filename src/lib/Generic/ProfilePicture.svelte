<script lang="ts">
	import DefaultPFPUser from '$lib/assets/abstract-user-flat-4.svg';
	import DefaultPFPGroup from '$lib/assets/default_banner_group.png';
	import { env } from '$env/dynamic/public';

	export let username = '',
		profilePicture: string | null | undefined = null,
		//TODO: Always display username, replace all instance of username with this file
		displayName = false,
		Class = '',
		//TODO: Fix so one can use size
		size: number = 2, // Change this to pixel size once we upgrade to tailwind 4
		userId: null | string | number = null,
		href = `/user?id=${userId}`,
		type: 'user' | 'group' = 'user';

	const DefaultPFP = type === 'user' ? DefaultPFPUser : DefaultPFPGroup;
	// Change this to pixel size once we upgrade to tailwind 4
	$: sizeClass =
		size === 1
			? 'w-5 h-5' // 20px
			: size === 2
				? 'w-10 h-10' // 40px
				: size === 3
					? 'w-16 h-16' // 64px
					: size === 4
						? 'w-20 h-20' // 80px
						: 'w-10 h-10'; // fallback to default 40px

	// TODO: Fix this bad hardcoded solution and general solution for decreasing reliance on hardcoded solutions to API in urls
	$: if (profilePicture?.includes('api/api')) {
		profilePicture = profilePicture.replace('api/api', 'api');
	}
</script>

{#if userId}
	<a {href} class={`flex gap-4 items-center shrink-0 ${Class}`}>
		{#if !profilePicture || profilePicture === '' || profilePicture === 'null'}
			<img src={DefaultPFP} alt="avatar" class={`${sizeClass} rounded-full`} />
		{:else}
			<img
				src={`${env.PUBLIC_API_URL}${profilePicture}`}
				alt="avatar"
				class={`${sizeClass} rounded-full`}
			/>
		{/if}
		{#if displayName}
			<span
				class="max-w-[150px] overflow-hidden whitespace-nowrap overflow-ellipsis dark:text-darkmodeText"
				>{username}</span
			>
		{/if}
	</a>
{:else}
	<div class={`flex gap-2 items-center shrink-0 ${Class}`}>
		{#if !profilePicture || profilePicture === '' || profilePicture === 'null'}
			<img src={DefaultPFP} alt="avatar" class={`${sizeClass} rounded-full`} />
		{:else}
			<img
				src={`${env.PUBLIC_API_URL}${profilePicture}`}
				alt="avatar"
				class={`${sizeClass} rounded-full`}
			/>
		{/if}
		{#if displayName}
			<span
				class="max-w-[150px] overflow-hidden whitespace-nowrap overflow-ellipsis dark:text-darkmodeText"
				>{username}</span
			>
		{/if}
	</div>
{/if}
