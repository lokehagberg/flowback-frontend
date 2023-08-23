<script lang="ts">
	import Button         from '$lib/Generic/Button.svelte';
	import Layout         from '$lib/Generic/Layout.svelte';
	import Loader         from '$lib/Generic/Loader.svelte';
	import StatusMessage  from '$lib/Generic/StatusMessage.svelte';
	import TextInput      from '$lib/Generic/TextInput.svelte';
	import {fetchRequest} from '$lib/FetchRequest';
	import Fa             from 'svelte-fa/src/fa.svelte';
	import {faPaperPlane} from
		'@fortawesome/free-solid-svg-icons/faPaperPlane';

	const
		{statusMessageFormatter} = StatusMessage;
	let
		name : string = "",
		number : string = "",
		loading : bool = false,
		status : StatusMessageInfo;
	const addAccount = async ()=>{
		loading = true;
		const formData = new FormData();

		formData.append("account_name", name);
		formData.append("account_number", number);
		const {res, json} = await fetchRequest(
			"POST", "ledger/accounts/create",
			formData, true, false
		);
		if (!res.ok) {
			status = statusMessageFormatter(res, json);
			loading = false;
			return;
		}
		window.location.href = "/accounts";
		loading = false;
	};
</script>
<svelte:head>
	<title>Flowback: Adding an Account</title>
</svelte:head>
<Layout centering>
	<Loader bind:loading>
		<form
			on:submit|preventDefault={addAccount}
			class="
				flex mt-6 mb-6 absolute left-1/2 -translate-x-1/2 items-start
				justify-center gap-8 md:mt-8 w-[1500px]
			"
		>
			<div class="bg-white p-6 shadow-xl flex flex-col gap-6 md:w-2/5">
				<h1 class="text-2xl">Add an Account</h1>
				<TextInput label="Name" bind:value={name} required/>
				<TextInput label="Number" bind:value={number} required/>

				<StatusMessage bind:status/>
				<Button type="submit" disabled={loading}>
					<div class="flex justify-center gap-3 items-center">
						<Fa icon={faPaperPlane}/>
						Add Account
					</div>
				</Button>
			</div>
		</form>
	</Loader>
</Layout>
