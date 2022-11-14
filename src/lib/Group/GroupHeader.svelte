<script lang="ts">
	import type { GroupDetails, SelectablePage } from './interface';
	import { _ } from 'svelte-i18n';
	export let selectedPage: SelectablePage;
	export let group: GroupDetails;
	export let memberCount: number;
</script>

<div class="relative flex justify-center">
	<img class="cover " src={`${import.meta.env.VITE_API}${group.cover_image}`} alt="cover" />
	<img
		class="h-36 w-36 absolute -bottom-8 left-8 profile rounded-full"
		src={`${import.meta.env.VITE_API}${group.image}`}
		alt="profile"
	/>
</div>
<div class="bg-white pt-12 flex justify-between align-middle pl-4 pr-4 pb-4">
	<h1 class="text-3xl hover:underline cursor-pointer" on:click={() => (selectedPage = 'flow')}>
		{group.name}
	</h1>
	<p class="text-xl">{memberCount} {$_('members')}</p>
</div>

<style>
	img.cover {
		aspect-ratio: 4;
		/* width: 100%; */
	}

	img.profile {
		width: 100px;
		height: 100px;
	}
</style>
