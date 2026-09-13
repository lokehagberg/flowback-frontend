<script lang="ts">
	import { faArrowLeft	} from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import SideHeaderIcon from './SideHeaderIcon.svelte';
	import { onNavigate } from '$app/navigation';
	import SideHeader from './SideHeader.svelte';
	import { onMount } from 'svelte';

	const pageTitles: Record<string, string> = {
		'home': 'Home',
		'groups': 'Groups',
		'kanban': 'Tasks',
		'schedule': 'Schedule',
		'ledger': 'Ledger',
		'delegations': 'Delegation',
		'user': 'User Profile',
		'user/settings': 'Settings',
	};

	let sideHeaderOpen = false, selectedHref = '';

	onMount(() => {
		selectedHref = window.location.pathname.slice(1);
	});

	onNavigate(() => {
		selectedHref = window.location.pathname.slice(1);
	});

</script>

<div class="relative w-full pb-4 mb-6">
  <div class="fixed top-0 left-0 right-0 z-[110] shadow-md bg-white dark:bg-gray-900 px-4 py-2 border-b border-gray-200 dark:border-gray-700 grid grid-cols-3 items-center">
		{#if selectedHref !== 'home'}
			<button
				class="text-gray-600 hover:text-primary dark:text-secondary transition-colors"
				on:click={() => history.back()}
			>
				<Fa icon={faArrowLeft} />
			</button>
		{:else if selectedHref === 'home'}
			<div></div>
		{/if}
    <h1 class="text-xl text-primary dark:text-secondary font-semibold text-center">
      {$_(pageTitles[selectedHref] || 'Flowback')}
    </h1>

    <div class="justify-self-end">
      <SideHeaderIcon bind:sideHeaderOpen />
      <SideHeader bind:sideHeaderOpen />
    </div>
  </div>
</div>