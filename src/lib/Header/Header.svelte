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
	import {
		env
	} from "$env/dynamic/public";

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
			profileImage = `${env.PUBLIC_API_URL}${
					env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
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
				src={env.PUBLIC_LOGO === 'REFORUM' ? Reforum : Logo}
				class="w-32 cursor-pointer"
				alt="flowback logo"
			/></a
		>
		<div class="!flex justify-between md:w-[80vw]">
			<nav class="flex justify-evenly md:justify-center md:gap-[4vw] w-[70vw]">
				{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === "TRUE")}
					<HeaderIcon icon={faHome} text="Home" href="home" color={darkMode ? 'white' : 'black'} />
					<!-- <HeaderIcon icon={faGlobeEurope} text="Public" href="public" /> -->
					<HeaderIcon
					icon={faUserFriends}
					text="Groups"
					href="groups"
					color={darkMode ? 'white' : 'black'}
					/>
					{/if}
					{#if env.PUBLIC_ONE_GROUP_FLOWBACK === "TRUE"}
					<HeaderIcon icon={faHome} text="Home" href="groups/1" color={darkMode ? 'white' : 'black'} />
				{/if}
				<HeaderIcon
					icon={faCalendarWeek}
					text="My Schedule"
					href="schedule"
					color={darkMode ? 'white' : 'black'}
				/>

				{#if env.PUBLIC_MODE === 'DEV'}
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
				{#if env.PUBLIC_MODE === 'DEV'}
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
					class="dark:text-darkmodeText"
					title={`Enable ${darkMode ? 'lightmode' : 'darkmode'}`}
					on:keydown={() => {}}
					on:click={() => {
						changeDarkMode(darkMode ? 'light' : 'dark');
						darkMode = !darkMode;
					}}
				>
					{#if darkMode}
						<Fa icon={faSun} />
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
