<script lang="ts">
	import CrossButton from '$lib/Generic/CrossButton.svelte';

	import Modal from '$lib/Generic/Modal.svelte';

	const logOut = () => {
		localStorage.removeItem('token');
		window.location.href = '/';
	};

	const navs = [
		{
			title: 'User profile',
			action: () => (window.location.href = '/user')
		},
		{ title: 'Support', action: () => (open = true) },
		{ title: 'Tools' },
		{ title: 'Logout', action: logOut }
	];

	let open = true;
</script>

<div class="absolute right-0 bg-gray-500">
	{#each navs as nav}
		<div class="cursor-pointer hover:underline" on:click={nav.action}>{nav.title}</div>
	{/each}
</div>

<Modal {open}>
	<div slot="header" class="p-4">
		<h1 class="text-sm text-left p-0">Support</h1>
		<CrossButton action={() => (open = false)} />
	</div>

	<div slot="body" class="text-left">
		<div>Support between 12:00 and 17:00 CET</div>
		<div>Number: +46737482562</div>
		<div>Mail: flowbacktask@gmail.com</div>
		<div>For questions about Metamask, contact the Metamask team.</div>
	</div>
</Modal>
