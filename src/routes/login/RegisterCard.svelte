<script lang="ts">
	import TextInput from './TextInput.svelte';

	import './index.css';

	let username: String;
	let email: String;

	async function registerAccount(e: any) {
		e.preventDefault();
		const response = await fetch('https://v2.flowback.org/register', {
			method: 'POST',
			headers: {
				Accept: 'application/json',
				'Content-Type': 'application/json',
				'Access-Control-Allow-Origin': '*'
			},
			body: `{
     "Username": ${username},
     "Email": ${email},
    }`
		});

		response.json().then((data) => {
			console.log(data);
		});
	}
</script>

<form class="flex flex-col items-center">
	<TextInput label={'Username'} bind:value={username} />
	<TextInput label={'Email'} bind:value={email} />

	<button
		on:click={registerAccount}
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded">Submit</button
	>
</form>
