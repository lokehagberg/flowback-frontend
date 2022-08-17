<script lang="ts">
	import CrossButton from '$lib/Generic/CrossButton.svelte';

	import Modal from '$lib/Generic/Modal.svelte';

	const logOut = () => {
		localStorage.removeItem('token');
		window.location.href = '/';
	};

	const handleCoDocumentCreation = () => {};

	const navs = [
		{
			title: 'User profile',
			action: () => (window.location.href = '/user')
		},
		{ title: 'Support', action: () => (open_support = true) },
		{ title: 'Tools', action: () => (open_tools = true) },
		{ title: 'Logout', action: logOut }
	];

	let open_support = false;
	let open_tools = false;
</script>

<div class="absolute right-0 bg-gray-500 z-50 select-none">
	{#each navs as nav}
		<div class="cursor-pointer hover:underline" on:click={nav.action}>{nav.title}</div>
	{/each}
</div>

<Modal open={open_support}>
	<div slot="header" class="p-4">
		<h1 class="text-sm text-left p-0">Support</h1>
		<CrossButton action={() => (open_support = false)} />
	</div>

	<div slot="body" class="text-left">
		<div>Support between 12:00 and 17:00 CET</div>
		<div>Number: +46737482562</div>
		<div>Mail: flowbacktask@gmail.com</div>
		<div>For questions about Metamask, contact the Metamask team.</div>
	</div>
</Modal>

<Modal open={open_tools}>
	<div slot="header" class="p-4">
		<h1 class="text-sm text-left p-0">Tools</h1>
		<CrossButton action={() => (open_tools = false)} />
	</div>

	<div slot="body" class="text-left">
		<div class="py-3 mb-2">
			Click this button to create a co-document, share the link for others to edit it. Remember to
			save the link.
		</div>
		<div class="grupper-card row g-2 clickable">
			<div class="text-center my-2 noSelect">
				<div on:click={handleCoDocumentCreation}>+ Create Co-Document</div>
			</div>
		</div>
	</div>
</Modal>
