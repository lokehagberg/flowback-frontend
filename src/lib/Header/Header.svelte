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
	import Reforum from '$lib/assets/Reforum.png';
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import SideHeader from './SideHeader.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import Notifications from './Notifications.svelte';
	import { changeDarkMode } from '$lib/Generic/DarkMode';

	let sideHeaderOpen = false,
		notificationOpen = false,
		profileImage = DefaultPFP;

	onMount(() => {
		getProfileImage();
	});

	const getProfileImage = async () => {
		const { res, json } = await fetchRequest('GET', 'user');

		if (res.ok && json.profile_image)
			profileImage = `${import.meta.env.VITE_API}${json.profile_image}`;
	};
</script>

<!-- TODO have two layers one for menu buttons for the middle and another layer on flowback/notification/pfp -->

<div class="sticky z-50 w-100 top-0">
	<header
		class="md:flex justify-between flex-col md:flex-row items-center p-1.5 px-3 bg-white shadow select-none"
	>
		<a href="/home" class="md:w-auto"
			><img
				src={import.meta.env.VITE_LOGO === 'REFORUM' ? Reforum : Logo}
				class="w-32 cursor-pointer"
				alt="flowback logo"
			/></a
		>
		<nav class="inline-flex">
			<HeaderIcon icon={faHome} text="Home" href="home" />
			<!-- <HeaderIcon icon={faGlobeEurope} text="Public" href="public" /> -->
			<HeaderIcon icon={faUserFriends} text="Groups" href="groups" />
			<HeaderIcon icon={faCalendarWeek} text="Schedule" href="schedule" />

			{#if import.meta.env.VITE_MODE === 'DEV'}
				<HeaderIcon icon={faChartBar} text="Prediction" href="prediction" />
			{/if}
			<HeaderIcon icon={faList} text="My Kanban" href="kanban" />
		</nav>

		<div
			id="side-header"
			class="flex gap-4 items-center float-right cursor-pointer hover:bg-grey-800"
		>
			<span on:click={() => changeDarkMode(localStorage.theme === 'light' ? 'dark' : 'light')}>Darkmode</span>
			<Notifications />

			<div on:click={() => (sideHeaderOpen = !sideHeaderOpen)}>
				<img
					class={`w-8 h-8 rounded-full ${sideHeaderOpen && 'border border-blue-500 border-4'}`}
					src={profileImage}
					alt="default pfp"
				/>
			</div>
		</div>
	</header>

	<SideHeader bind:sideHeaderOpen />
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
