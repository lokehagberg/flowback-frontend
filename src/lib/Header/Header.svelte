<script lang="ts">
	import HeaderIcon from './HeaderIcon.svelte';
	import Logo from '$lib/assets/Logo.png';
	import Reforum from '$lib/assets/ReforumTransparent.png';
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import SideHeader from './SideHeader.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import Notifications from './Notifications.svelte';
	import { changeDarkMode } from '$lib/Generic/DarkMode';
	import type { Group, GroupUser } from '$lib/Group/interface';
	import { pfpStore } from '$lib/Login/stores';
	import {
		faCalendarWeek,
		faCoins,
		faHome,
		faList,
		faMoon,
		faUserFriends,
		faCog
	} from '@fortawesome/free-solid-svg-icons';
	import Sun from './Sun.svelte';
	import { env } from '$env/dynamic/public';
	import Fa from 'svelte-fa';
	import CalendarIcon from '$lib/assets/Date_range_fill.svg';
	import HomeIcon from '$lib/assets/Home_fill.svg';
	import KanbanIcon from '$lib/assets/darhboard.svg';
	import AutomationIcon from '$lib/assets/Rectangle 4202.svg';

	let sideHeaderOpen = false,
		profileImage: string | null = DefaultPFP,
		darkMode: boolean = false,
		isAdmin = false,
		ledgerExists = true,
		selectedHref = '';

	onMount(() => {
		if (location.pathname !== '/login') {
			getProfileImage();
			setPfP();
		}

		ensureDarkMode();

		pfpStore.subscribe((s) => {
			getProfileImage();
		});
	});

	const setPfP = () => {
		if (!profileImage) getProfileImage();
		else {
			const pfpLink = localStorage.getItem('pfp-link');
			console.log(typeof pfpLink, 'PFPLINK');

			if (pfpLink !== 'null') profileImage = pfpLink;
			else profileImage = null;
		}
	};

	const ensureDarkMode = () => {
		if (localStorage.getItem('theme') === 'light') {
			darkMode = false;
			return;
		} else if (localStorage.getItem('theme') === 'dark') {
			darkMode = true;
			return;
		}

		if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
			darkMode = true;
		} else darkMode = false;
	};

	const getProfileImage = async () => {
		const { res, json } = await fetchRequest('GET', 'user');

		if (res.ok && json.profile_image)
			profileImage = `${env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''}${json.profile_image}`;

		localStorage.setItem(
			'pfp-link',
			`${env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''}${json.profile_image}`
		);

		if (env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE') getIsAdmin(json?.id);
	};

	const getIsAdmin = async (userId: number) => {
		const { res, json } = await fetchRequest('GET', 'group/list');
		if (!res.ok) return;
		const group: Group = json?.results[0];
		{
			const { res, json } = await fetchRequest('GET', `group/${group.id}/users`);
			if (!res.ok) return;

			const admins = json?.results.filter((user: GroupUser) => user.is_admin === true);

			if (admins.find((admin: GroupUser) => admin.user.id === userId)) isAdmin = true;
		}
	};
</script>

<div class="dark:text-darkmodeText sticky z-50 w-100 top-0" id="header">
	<header
		class="md:flex justify-between flex-row items-center p-1.5 px-3 bg-white shadow select-none dark:bg-darkobject"
	>
		<a
			href={env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' ? '/groups/1' : '/home'}
			class="md:w-auto flex justify-center md:flex-none"
			><img
				src={env.PUBLIC_LOGO === 'REFORUM' ? Reforum : Logo}
				class="w-32 cursor-pointer"
				alt="flowback logo"
			/></a
		>
		<div class="!flex justify-between md:w-[80vw]">
			<nav class="flex p-6 justify-evenly md:justify-center md:gap-[4vw] w-[70vw]">
				{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
					<HeaderIcon
						icon={
				HomeIcon}
						text="Home"
						href="home"
						bind:selectedHref
						color={darkMode ? 'white' : 'black'}
					/>
					<!-- <HeaderIcon icon={faGlobeEurope} text="Public" href="public" /> -->
					<HeaderIcon
						icon={faUserFriends}
						text="Groups"
						href="groups"
						bind:selectedHref
						color={darkMode ? 'white' : 'black'}
					/>
				{/if}
				{#if env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE'}
					<HeaderIcon
						icon={HomeIcon}
						text="Home"
						href="groups/1"
						bind:selectedHref
						color={darkMode ? 'white' : 'black'}
					/>
				{/if}
				<HeaderIcon
					icon={CalendarIcon}
					text="Schedule"
					href="schedule"
					bind:selectedHref
					color={darkMode ? 'white' : 'black'}
				/>
				
				<HeaderIcon
					icon={KanbanIcon}
					text="Kanban"
					href="kanban"
					bind:selectedHref
					color={darkMode ? 'white' : 'black'}
				/>

				{#if env.PUBLIC_FLOWBACK_LEDGER_MODULE === 'TRUE'}
					<HeaderIcon
						icon={faCoins}
						text={!(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE') ? 'My Ledger' : 'Group Ledger'}
						href="ledger"
						bind:selectedHref
						color={darkMode ? 'white' : 'black'}
					/>
				{/if}

				{#if env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE'}
					<HeaderIcon
						icon={AutomationIcon}
						text={'Automate'}
						href="automate"
						bind:selectedHref
						color={darkMode ? 'white' : 'black'}
					/>
				{:else}
					<HeaderIcon
						icon={AutomationIcon}
						text={'Delegations'}
						href="automate"
						bind:selectedHref
						color={darkMode ? 'white' : 'black'}
					/>
				{/if}
			</nav>

			<div id="side-header" class="flex gap-4 items-center float-right hover:bg-grey-800">
				<button
					class="dark:text-darkmodeText cursor-pointer pl-2"
					title={`Enable ${darkMode ? 'lightmode' : 'darkmode'}`}
					on:keydown={() => {}}
					on:click={() => {
						changeDarkMode(darkMode ? 'light' : 'dark');
						darkMode = !darkMode;
					}}
				>
					{#if darkMode}
						<Sun />
					{:else}
						<Fa icon={faMoon} />
					{/if}
				</button>
				<Notifications />

				<button on:click={() => (sideHeaderOpen = !sideHeaderOpen)}>
					<img
						src={profileImage ? `${env.PUBLIC_API_URL}${profileImage}` : DefaultPFP}
						class={`w-8 h-8 rounded-full cursor-pointer ${
							sideHeaderOpen && 'border-blue-500 border-4'
						}`}
						alt="default pfp"
					/>
				</button>
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

	/* header > .inline-flex {
		gap: calc(8vw - 60px);
	} */

	header {
		flex-wrap: wrap-reverse;
		padding: 0rem 1rem;
	}

	/* @media only screen and (max-width: 768px) {
		header > .inline-flex {
			gap: calc(15vw - 70px);
		}
	} */

	@media only screen and (max-width: 500px) {
		header > div:last-child {
			float: none;
			display: block;
		}
	}
</style>
