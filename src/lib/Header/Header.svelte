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
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import SideHeader from './SideHeader.svelte';

	let sideHeaderOpen = false;
</script>

<div class="sticky z-50 w-full top-0">
	<header
		class="md:flex justify-between flex-col md:flex-row items-center p-1.5 bg-white shadow select-none"
	>
		<a href="/home" class="md:w-auto"
			><img src={Logo} class="w-32 cursor-pointer" alt="flowback logo" /></a
		>
		<div class="inline-flex">
			<HeaderIcon icon={faHome} text="Home" href="home" />
			<!-- <HeaderIcon icon={faGlobeEurope} text="Public" href="public" /> -->
			<HeaderIcon icon={faUserFriends} text="Groups" href="groups" />
			<HeaderIcon icon={faCalendarWeek} text="Schedule" href="schedule" />

			{#if import.meta.env.VITE_MODE === 'DEV'}
				<HeaderIcon icon={faChartBar} text="Prediction" href="prediction" />
			{/if}
			<HeaderIcon icon={faList} text="Kanban" href="kanban" />
		</div>

		<div
			class="inline-block float-right cursor-pointer hover:bg-grey-800"
			on:click={() => (sideHeaderOpen = !sideHeaderOpen)}
		>
			<img class={`w-8 h-8 rounded-full ${sideHeaderOpen && 'border border-blue-500 border-4'}`} src={DefaultPFP} alt="default pfp" />
		</div>
	</header>
	{#if sideHeaderOpen}
		<SideHeader />
	{/if}
</div>

<!-- Kind of an ugly fix for mobile phones. TODO: More elegant solution  -->
<style>
	header:nth-child(1) {
		align-self: stretch;
	}

	header > .inline-flex {
		gap: calc(8vw - 60px);
	}

	header {
		flex-wrap: wrap-reverse;
	}

	@media only screen and (max-width: 768px) {
		header > .inline-flex {
			gap: calc(15vw - 70px);
		}
	}

	@media only screen and (max-width: 500px) {
		header > div:last-child {
			float: none;
			display: block;
		}
	}
</style>
