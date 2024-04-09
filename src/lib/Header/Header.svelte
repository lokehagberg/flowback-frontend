<script lang="ts">
	import HeaderIcon from './HeaderIcon.svelte';
	//Temporary fix due to bug with Sveltekit, it should be "import {faHome, faGlobeEurope, ...} from @fortawesome/free-solid-svg-icons"
	import { faHome } from '@fortawesome/free-solid-svg-icons/faHome';
	import { faSun } from '@fortawesome/free-solid-svg-icons/faSun';
	import { faUserFriends } from '@fortawesome/free-solid-svg-icons/faUserFriends';
	import { faCalendarWeek } from '@fortawesome/free-solid-svg-icons/faCalendarWeek';
	import { faChartBar } from '@fortawesome/free-solid-svg-icons/faChartBar';
	import { faList } from '@fortawesome/free-solid-svg-icons/faList';
	import { faMoneyBill } from '@fortawesome/free-solid-svg-icons/faMoneyBill';
	import Logo from '$lib/assets/Logo.png';
	import Reforum from '$lib/assets/Reforum.png';
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import SideHeader from './SideHeader.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import Notifications from './Notifications.svelte';
	import { changeDarkMode } from '$lib/Generic/DarkMode';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faMoon } from '@fortawesome/free-solid-svg-icons/faMoon';
	// import { accountsStore } from '$lib/Account/stores';
	import { faCoins } from '@fortawesome/free-solid-svg-icons';

	let sideHeaderOpen = false,
		profileImage = DefaultPFP,
		darkMode: boolean | null = null,
		ledgerExists: boolean = false;
	//TODO: The <HeaderIcon> component should handle default darkMode

	onMount(() => {
		getProfileImage();
		darkMode = localStorage.theme === 'dark';
		checkForLedgerModule();
	});

	const getProfileImage = async () => {
		const { res, json } = await fetchRequest('GET', 'user');

		if (res.ok && json.profile_image)
			profileImage = `${import.meta.env.VITE_API}${
				import.meta.env.VITE_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
			}${json.profile_image}`;
	};

	const checkForLedgerModule = async () => {
		// const accounts = await accountsStore.get();
		// ledgerExists = accounts.loaded;
	};
</script>

<!-- TODO have two layers one for menu buttons for the middle and another layer on flowback/notification/pfp -->

<div class="dark:text-darkmodeText sticky z-50 w-100 top-0">
	<header
		class="md:flex justify-between flex-row items-center p-1.5 px-3 bg-white shadow select-none dark:bg-darkobject"
	>
		<a href="/home" class="md:w-auto flex justify-center md:flex-none"
			><img
				src={import.meta.env.VITE_LOGO === 'REFORUM' ? Reforum : Logo}
				class="w-32 cursor-pointer"
				alt="flowback logo"
			/></a
		>
		<div class="!flex justify-between md:w-[80vw]">
			<nav class="flex justify-evenly md:justify-center md:gap-[4vw] w-[70vw]">
				{#if !(import.meta.env.VITE_ONE_GROUP_FLOWBACK === 'TRUE')}
					<HeaderIcon icon={faHome} text="Home" href="home" color={darkMode ? 'white' : 'black'} />
					<!-- <HeaderIcon icon={faGlobeEurope} text="Public" href="public" /> -->
					<HeaderIcon
						icon={faUserFriends}
						text="Groups"
						href="groups"
						color={darkMode ? 'white' : 'black'}
					/>
				{/if}
				{#if import.meta.env.VITE_ONE_GROUP_FLOWBACK === 'TRUE'}
					<HeaderIcon
						icon={faHome}
						text="Home"
						href="groups/1"
						color={darkMode ? 'white' : 'black'}
					/>
				{/if}
				<HeaderIcon
					icon={faCalendarWeek}
					text="My Schedule"
					href="schedule"
					color={darkMode ? 'white' : 'black'}
				/>

				{#if import.meta.env.VITE_MODE === 'DEV'}
					<HeaderIcon
						icon={faChartBar}
						text="Prediction"
						href="prediction"
						color={darkMode ? 'white' : 'black'}
					/>
				{/if}
				<HeaderIcon
					icon={faList}
					text="My Kanban"
					href="kanban"
					color={darkMode ? 'white' : 'black'}
				/>
				<HeaderIcon
					icon={faCoins}
					text="My Ledger"
					href="ledger"
					color={darkMode ? 'white' : 'black'}
				/>
				<!-- <HeaderIcon
					icon={faList}
					text="My Kanban"
					href="kanban"
					color={darkMode ? 'white' : 'black'}
				/> -->
				{#if import.meta.env.VITE_MODE === 'DEV'}
					{#if ledgerExists}
						<HeaderIcon
							icon={faMoneyBill}
							text="Account"
							href="ledger"
							color={darkMode ? 'white' : 'black'}
						/>
					{/if}
				{/if}
			</nav>

			<div
				id="side-header"
				class="flex gap-4 items-center float-right cursor-pointer hover:bg-grey-800"
			>
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<span
					class="dark:text-darkmodeText p-2"
					title={`Enable ${darkMode ? 'lightmode' : 'darkmode'}`}
					on:keydown={() => {}}
					on:click={() => {
						changeDarkMode(darkMode ? 'light' : 'dark');
						darkMode = !darkMode;
					}}
				>
					{#if darkMode}
						<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="25" height="25">
							<!-- Sun rays -->
							<line x1="50" y1="10" x2="50" y2="90" stroke="white" stroke-width="8" />
							<line x1="10" y1="50" x2="90" y2="50" stroke="white" stroke-width="8" />
							<line x1="28" y1="28" x2="72" y2="72" stroke="white" stroke-width="8" />
							<line x1="72" y1="28" x2="28" y2="72" stroke="white" stroke-width="8" />
							<line x1="22" y1="78" x2="78" y2="22" stroke="white" stroke-width="8" />
							<line x1="78" y1="78" x2="22" y2="22" stroke="white" stroke-width="8" />
							<line x1="28" y1="72" x2="72" y2="28" stroke="white" stroke-width="8" />
							<line x1="72" y1="72" x2="28" y2="28" stroke="white" stroke-width="8" />
							<!-- Sun center -->
							<circle cx="50" cy="50" r="25" fill="white" />
						</svg>
					{:else}
						<Fa icon={faMoon} />
					{/if}
				</span>
				<Notifications />

				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<div on:keydown={() => {}} on:click={() => (sideHeaderOpen = !sideHeaderOpen)}>
					<img
						class={`w-8 h-8 rounded-full ${sideHeaderOpen && 'border-blue-500 border-4'}`}
						src={profileImage}
						alt="default pfp"
					/>
				</div>
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
