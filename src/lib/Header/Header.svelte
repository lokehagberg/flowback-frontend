<script>
	import HeaderIcon from './HeaderIcon.svelte';
	//Temporary fix due to bug with Sveltekit, it should be "import {faHome, faGlobeEurope, ...} from @fortawesome/free-solid-svg-icons"
	import { faHome } from '@fortawesome/free-solid-svg-icons/faHome';
	import { faGlobeEurope } from '@fortawesome/free-solid-svg-icons/faGlobeEurope';
	import { faUserFriends } from '@fortawesome/free-solid-svg-icons/faUserFriends';
	import { faCalendarWeek } from '@fortawesome/free-solid-svg-icons/faCalendarWeek';
	import { faChartBar } from '@fortawesome/free-solid-svg-icons/faChartBar';
	import { faList } from '@fortawesome/free-solid-svg-icons/faList';
	import Logo from '$lib/assets/Logo.png';
	import SideHeader from './SideHeader.svelte';
	let sideHeaderOpen = false;
</script>

<div class="fixed z-50 w-full top-0">
	<header class="flex justify-between items-center p-1.5 bg-white shadow select-none">
		<a href="/home"><img src={Logo} class="w-32 cursor-pointer" alt="flowback logo" /></a>
		<div class="flex gap-8">
			<HeaderIcon icon={faHome} text="Home" href="home" />
			<HeaderIcon icon={faGlobeEurope} text="Public" href="public" />
			<HeaderIcon icon={faUserFriends} text="Groups" href="groups" />
			<HeaderIcon icon={faCalendarWeek} text="Schedule" href="schedule" />
			<HeaderIcon icon={faChartBar} text="Prediction" href="prediction" />
			<HeaderIcon icon={faList} text="Kanban" href="kanban" />
		</div>

		<div
			class="flex gap-2 items-center cursor-pointer hover:bg-grey-800"
			on:click={() => (sideHeaderOpen = !sideHeaderOpen)}
		>
			<div class="bg-red-500 w-5 h-5" />
			<div class="">name</div>
		</div>
	</header>
	{#if sideHeaderOpen}
		<SideHeader />
	{/if}
</div>
