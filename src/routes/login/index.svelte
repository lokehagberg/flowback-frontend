<script lang="ts">
	import RegisterCard from '../../lib/Login/RegisterCard.svelte';
	import LoginCard from '../../lib/Login/LoginCard.svelte';
	import ForgotPasswordCard from '../../lib/Login/ForgotPasswordCard.svelte';
	import VerifyCard from '$lib/Login/VerifyCard.svelte';
	import NewPasswordCard from '$lib/Login/NewPasswordCard.svelte';

	let selectedPage = 'Login';

	if (localStorage.getItem('token')) window.location.href = '/';
</script>

<svelte:head>
	<title>Login to Flowback</title>
</svelte:head>

<div class="flex flex-col items-center">
	<div class="mt-14">
		<img src="Logo.png" class="w-44" alt="flowback logo" />
	</div>
	<div class="bg-white w-4/5 sm:w-1/2 mt-14 rounded shadow-lg">
		<div class="flex justify-around mt-2 border-b">
			<div
				class="cursor-pointer border-blue-500 pb-2 w-24 text-center text-xl font-light text-gray-500"
				class:border-b-2={selectedPage === 'Login'}
				on:click={() => (selectedPage = 'Login')}
			>
				Login
			</div>
			<div
				class="cursor-pointer border-blue-500 pb-2 w-24 text-center text-xl font-extralight text-gray-500"
				class:border-b-2={selectedPage === 'Register'}
				on:click={() => (selectedPage = 'Register')}
			>
				Register
			</div>
		</div>
		{#if selectedPage === 'Login'}
			<LoginCard bind:selectedPage />
		{:else if selectedPage === 'Register'}
			<RegisterCard bind:selectedPage />
		{:else if selectedPage === 'Verify'}
			<VerifyCard bind:selectedPage />
		{:else if selectedPage === 'ForgotPassword'}
			<ForgotPasswordCard bind:selectedPage />
		{:else if selectedPage === 'NewPassword'}
			<NewPasswordCard bind:selectedPage />
		{/if}
	</div>
</div>
