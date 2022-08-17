<script lang="ts">
	const logOut = () => {
		localStorage.removeItem('token');
		window.location.href = '/';
	};

	const navs = [
		{
			title: 'User profile',
			action: () => {
				window.location.href = '/user';
			}
		},
		{ title: 'Support' },
		{ title: 'Tools' },
		{ title: 'Logout', action: logOut }
	];
</script>

<div class="absolute right-0 bg-gray-500">
	{#each navs as nav}
		<div class="cursor-pointer hover:underline" on:click={nav.action}>{nav.title}</div>
	{/each}
</div>
