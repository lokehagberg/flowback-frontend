<script lang="ts">
	import { _ } from 'svelte-i18n';
	import Modal from '$lib/Generic/Modal.svelte';
	import { onMount } from 'svelte';
	import TermsOfService from '$lib/Login/TermsOfService.svelte';
	import { goto } from '$app/navigation';
	import { env } from '$env/dynamic/public';

	export let sideHeaderOpen = false;

	let open_tos = false,
		open_support = false,
		open_tools = false;

	const logOut = () => {
		localStorage.removeItem('token');
		goto('/login');
	};

	//TODO: Implement codocument creation
	const handleCoDocumentCreation = () => {};

	const closeWindowWhenClickingOutside = () => {
		window.addEventListener('click', function (e) {
			const notificationListElement = document.getElementById(`side-header`);
			if (
				sideHeaderOpen &&
				//@ts-ignore
				!notificationListElement?.contains(e.target)
			) {
				sideHeaderOpen = false;
			}
		});
	};

	const navs = [
		{
			title: 'User Profile',
			action: () => goto('/user')
		},
		{ title: 'Support', action: () => (open_support = true) },
		{ title: 'TOS', action: () => (open_tos = true) },
		{ title: 'Log Out', action: logOut }
	];

	onMount(() => {
		closeWindowWhenClickingOutside();
	});
</script>

<!-- TODO: Relative works great for phones -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	class:hidden={!sideHeaderOpen}
	class="absolute right-0 bg-white z-50 select-none shadow slide-animation dark:bg-darkobject dark:text-darkmodeText"
	id="side-header"
	on:click={() => (sideHeaderOpen = !sideHeaderOpen)}
	on:keydown
>
	{#each navs as nav}
		<div
			class="cursor-pointer pt-3 pb-3 pr-10 pl-6 border-b border-gray-200 border hover:shadow hover:bg-blue-300 transition-all"
			on:click={nav.action}
			on:keydown
		>
			{$_(nav.title)}
		</div>
	{/each}
</div>

<Modal bind:open={open_support}>
	<div slot="header" class="p-4">
		{$_('Support')}
	</div>

	<div slot="body" class="text-left">
		<div>{$_('Phone support is only between 15:30 and 17:30 CET')}</div>
		<div>{$_('Number: +46737482562')}</div>
		<div>{$_(`Mail: ${env.PUBLIC_SUPPORT_MAIL}`)}</div>
		<!-- <div>{$_('For questions about Metamask, contact the Metamask team.')}</div> -->
	</div>
</Modal>

<Modal bind:open={open_tools}>
	<div slot="header" class="p-4">
		{$_('Tools')}
	</div>

	<div slot="body" class="text-center">
		<div class="py-3 mb-2">
			{$_(
				'Click this button to create a co-document, share the link for others to edit it. Remember to save the link.'
			)}
		</div>
		<div class="grupper-card row g-2 clickable">
			<div class="text-center my-2 noSelect">
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<div on:keydown on:click={handleCoDocumentCreation}>+ {$_('Create Co-Document')}</div>
			</div>
		</div>
	</div>
</Modal>

<Modal bind:open={open_tos} Class="h-[90%] overflow-y-scroll">
	<div slot="body" class="">
		<TermsOfService Class="!border-none !p-0 leading-8" />
	</div>
</Modal>

<style>
	@keyframes slide-animation {
		from {
			right: -100px;
		}
		to {
			right: 0;
		}
	}

	.slide-animation {
		animation-name: slide-animation;
		animation-duration: 300ms;
	}
</style>
