<script lang="ts">
	import HeaderIcon from './HeaderIcon.svelte';
	import Logo from '$lib/assets/Logo.png';
	import Reforum from '$lib/assets/ReforumTransparent.png';
	import SideHeader from './SideHeader.svelte';
	import Notifications from './Notifications.svelte';
	import { darkModeStore, toggleDarkMode } from '$lib/Generic/DarkMode';
	import {
		faCalendarDays,
		faCoins,
		faHouse,
		faMoon,
		faPeopleGroup,
		faArrowsSpin,
		faPeopleArrows,
		faListCheck
	} from '@fortawesome/free-solid-svg-icons';
	import Sun from './Sun.svelte';
	import { env } from '$env/dynamic/public';
	import Fa from 'svelte-fa';
	import { chatOpenStore } from '$lib/Chat/functions';
	import { isMobile } from '$lib/utils/isMobile';
	import { onNavigate } from '$app/navigation';
	import SideHeaderIcon from './SideHeaderIcon.svelte';

	let sideHeaderOpen = false,
		selectedHref = '';

	onNavigate(() => {
		selectedHref = window.location.pathname.slice(1);
	});
</script>

<header
	class="md:sticky md:top-0 fixed bottom-0 w-full z-[60] md:flex justify-between flex-row items-center px-5 bg-white select-none dark:bg-darkobject top-shadow shadow"
	id="header"
>
	<a
		href={env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' ? '/groups/1' : '/home'}
		on:click={() => chatOpenStore.set(false)}
		class="hidden md:block md:w-auto md:flex-none"
		><img
			src={env.PUBLIC_LOGO === 'REFORUM' ? Reforum : Logo}
			class="w-32 cursor-pointer"
			alt="flowback logo"
		/></a
	>
	<div class="!flex justify-between md:w-[80%]">
		<nav
			class="flex items-center p-5 justify-center gap-[10%] w-full md:w-[75%]"
		>
			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<HeaderIcon
					disableTextOnHover
					icon={faHouse}
					text="Home"
					href="home"
					bind:selectedHref
				/>
				<HeaderIcon
					disableTextOnHover
					icon={faPeopleGroup}
					text="Groups"
					href="groups"
					bind:selectedHref
				/>
			{/if}
			{#if env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE'}
				<HeaderIcon
					disableTextOnHover
					icon={faHouse}
					text="Home"
					href="groups/1"
					bind:selectedHref
				/>
			{/if}

			<HeaderIcon
				disableTextOnHover
				icon={faListCheck}
				text="Tasks"
				href="kanban"
				bind:selectedHref
			/>
			<HeaderIcon
				disableTextOnHover
				icon={faCalendarDays}
				text="Schedule"
				href="schedule"
				bind:selectedHref
			/>
			{#if env.PUBLIC_FLOWBACK_LEDGER_MODULE === 'TRUE'}
				<HeaderIcon
					disableTextOnHover
					icon={faCoins}
					text={!(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')
						? 'My Ledger'
						: 'Group Ledger'}
					href="ledger"
					bind:selectedHref
				/>
			{/if}

			{#if env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE'}
				<HeaderIcon
					disableTextOnHover
					icon={faArrowsSpin}
					text={'Automate'}
					href="automate"
					bind:selectedHref
				/>
			{:else}
				<HeaderIcon
					disableTextOnHover
					icon={faPeopleArrows}
					text={'Delegation'}
					href="delegations"
					bind:selectedHref
				/>
			{/if}

			{#if $isMobile}
				<div class="flex flex-shrink-0">
					<SideHeaderIcon bind:sideHeaderOpen />
				</div>
			{/if}
		</nav>

		{#if !$isMobile}
			<div class="flex gap-4 items-center float-right hover:bg-grey-800">
				<div class="mr-5 flex gap-4 items-center">
					<button
						class="dark:text-darkmodeText cursor-pointer pl-2"
						title={`Enable ${$darkModeStore ? 'lightmode' : 'darkmode'}`}
						aria-label="Mode Toggle"
						on:click={toggleDarkMode}
					>
						{#if $darkModeStore}
							<Sun />
						{:else}
							<Fa icon={faMoon} size={'1.3x'} />
						{/if}
					</button>
					<Notifications />
				</div>
				<SideHeaderIcon bind:sideHeaderOpen />
			</div>
		{/if}
	</div>
	<SideHeader bind:sideHeaderOpen />
</header>

<style>
	@media only screen and (max-width: 768px) {
		.top-shadow {
			box-shadow: 0 -4px 6px -1px rgba(0, 0, 0, 0.1);
		}
	}
</style>
