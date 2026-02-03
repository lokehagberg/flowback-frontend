<script lang="ts">
	import Tab from '$lib/Generic/Tab.svelte';
	import Register from '$lib/Login/Register.svelte';
	import Login from '$lib/Login/Login.svelte';
	import ForgotPassword from '$lib/Login/ForgotPassword.svelte';
	import Verify from '$lib/Login/Verify.svelte';
	import NewPassword from '$lib/Login/NewPassword.svelte';
	import { onMount } from 'svelte';
	import Logo from '$lib/assets/Logo.png';
	import Reforum from '$lib/assets/ReforumTransparent.png';
	import { _ } from 'svelte-i18n';
	import { goto } from '$app/navigation';
	import { env } from '$env/dynamic/public';

	let selectedPage = 'Login';

	//Email is stored for automatic login when resetting password
	let email = '';

	onMount(() => {
		const params = new URLSearchParams(window.location.search);
		const emailParam = params.get('email');
		const verificationCode = params.get('verification_code');

		if (emailParam && verificationCode) {
			selectedPage = 'Verify';
			return;
		}

		if (localStorage.getItem('token')) goto('/home');
	});
</script>

<svelte:head>
	<title>{$_('Login to Flowback')}</title>
</svelte:head>

<div
	id="login-page"
	class="dark:!bg-darkbackground bg-purple-50 min-h-[110vh] flex flex-col items-center"
>
	<div class="mt-16">
		<img
			src={env.PUBLIC_LOGO === 'REFORUM' ? Reforum : Logo}
			alt={env.PUBLIC_LOGO === 'REFORUM' ? "Reforum Logo" : "Flowback Logo"}
			class="w-[300px]"
		/>
	</div>
	<div
		class="bg-white dark:bg-darkobject dark:text-darkmodeText mt-12 rounded shadow-lg w-full max-w-[600px]"
	>
		<Tab
			bind:selectedPage
			tabs={env.PUBLIC_DISABLE_ACCOUNT_CREATION === 'TRUE' ? ['Login'] : ['Login', 'Register']}
		/>
		<div>
			{#if selectedPage === 'Login'}
				<Login bind:selectedPage />
			{:else if selectedPage === 'Register'}
				<Register bind:selectedPage />
			{:else if selectedPage === 'Verify'}
				<Verify />
			{:else if selectedPage === 'GotMail'}
				{$_("A link has been sent to your email. Check the spam folder if you don't see it.")}
			{:else if selectedPage === 'ForgotPassword'}
				<ForgotPassword bind:selectedPage bind:email />
			{:else if selectedPage === 'NewPassword'}
				<NewPassword  />
			{/if}
		</div>
	</div>
</div>
