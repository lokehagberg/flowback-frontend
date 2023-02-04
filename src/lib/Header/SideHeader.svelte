<script lang="ts">
	import { _ } from 'svelte-i18n';
	import Modal from '$lib/Generic/Modal.svelte';

	const logOut = () => {
		localStorage.removeItem('token');
		window.location.href = '/';
	};

	//TODO: Implement codocument creation
	const handleCoDocumentCreation = () => {};

	const navs = [
		{
			title: 'User Profile',
			action: () => (window.location.href = '/user')
		},
		{ title: 'Support', action: () => (open_support = true) },
		// { title: 'Tools', action: () => (open_tools = true) },
		{ title: 'Log Out', action: logOut }
	];

	let open_support = false;
	let open_tools = false;
</script>

<!-- TODO: Relative works great for phones -->
<div class="absolute right-0 bg-white z-50 select-none shadow slide-animation">
	{#each navs as nav}
		<div
			class="cursor-pointer pt-3 pb-3 pr-10 pl-6 border-b border-gray-200 border hover:shadow hover:bg-blue-300 transition-shadow transition-colors"
			on:click={nav.action}
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
		<div>{$_('Support between 12:00 and 17:00 CET')}</div>
		<div>{$_('Number: +46737482562')}</div>
		<div>{$_('Mail: flowbacktask@gmail.com')}</div>
		<div>{$_('For questions about Metamask, contact the Metamask team.')}</div>
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
				<div on:click={handleCoDocumentCreation}>+ {$_('Create Co-Document')}</div>
			</div>
		</div>
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
