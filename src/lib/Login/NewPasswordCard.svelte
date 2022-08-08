<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	export let selectedPage: string;
	let password: string;
	let verification_code: string;

    async function registerAccount(e: any) {
		e.preventDefault();
		const response = await fetch('https://v2.flowback.org/forgot_password/verify', {
			method: 'POST',
			headers: {
				Accept: 'application/json',
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				password,
                verification_code
			})
		});

		if (response) selectedPage = 'Verify';
	}
</script>

<form class="flex flex-col items-center">
	<TextInput label={'New Password'} bind:value={password} type="password" />
	<TextInput label={'Verification Code'} bind:value={verification_code} />

	<input
		type="submit"
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer"
	/>
</form>
