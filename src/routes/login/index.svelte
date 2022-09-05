<script lang="ts">
  import Tab from '$lib/Generic/Tab.svelte';

	import RegisterCard from '../../lib/Login/Register.svelte';
	import LoginCard from '../../lib/Login/Login.svelte';
	import ForgotPasswordCard from '../../lib/Login/ForgotPassword.svelte';
	import VerifyCard from '$lib/Login/Verify.svelte';
	import NewPasswordCard from '$lib/Login/NewPassword.svelte';
	import { onMount } from 'svelte';

	let selectedPage = 'Login';

	onMount(() => {
		if (localStorage.getItem('token')) window.location.href = '/home';
	});

</script>

<svelte:head>
	<title>Login to Flowback</title>
</svelte:head>

<div class="flex flex-col items-center">
	<div class="mt-14">
		<img src="Logo.png" class="w-44" alt="flowback logo" />
	</div>
	<div class="bg-white w-4/5 sm:w-1/2 mt-14 rounded shadow-lg">
		<Tab bind:selectedPage tabs={['Login', 'Register']}/>
		<div class="">
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
</div>
