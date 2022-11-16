<script lang="ts">
	import Tab from '$lib/Generic/Tab.svelte';
	import RegisterCard from '$lib/Login/Register.svelte';
	import LoginCard from '$lib/Login/Login.svelte';
	import ForgotPasswordCard from '$lib/Login/ForgotPassword.svelte';
	import VerifyCard from '$lib/Login/Verify.svelte';
	import NewPasswordCard from '$lib/Login/NewPassword.svelte';
	import { onMount } from 'svelte';
	import Logo from '$lib/assets/Logo.png';
	import Reforum from '$lib/assets/Reforum.png';
	import { _ } from 'svelte-i18n';

	let selectedPage = 'Login';

	//Email is stored for automatic login when resetting password
	let email = ''

	onMount(() => {
		if (localStorage.getItem('token')) window.location.href = '/home';
	});
</script>

<svelte:head>
	<title>{$_('Login to Flowback')}</title>
</svelte:head>

<div class="flex flex-col items-center">
	<div class="mt-6">
		<img src={import.meta.env.VITE_LOGO === "REFORUM" ? Reforum : Logo} class="w-44" alt="flowback logo" />
	</div>
	<div class="bg-white mt-6 rounded shadow-lg w-full max-w-[600px]">
		<Tab bind:selectedPage tabs={['Login', 'Register']} />
		<div class="">
			{#if selectedPage === 'Login'}
				<LoginCard bind:selectedPage />
			{:else if selectedPage === 'Register'}
				<RegisterCard bind:selectedPage />
			{:else if selectedPage === 'Verify'}
				<VerifyCard />
			{:else if selectedPage === 'ForgotPassword'}
				<ForgotPasswordCard bind:selectedPage bind:email />
			{:else if selectedPage === 'NewPassword'}
				<NewPasswordCard bind:email/>
			{/if}
		</div>
	</div>
</div>