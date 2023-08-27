<script lang="ts">
	import Button         from '$lib/Generic/Button.svelte';
	import Layout         from '$lib/Generic/Layout.svelte';
	import Loader         from '$lib/Generic/Loader.svelte';
	import StatusMessage  from '$lib/Generic/StatusMessage.svelte';
	import TextInput      from '$lib/Generic/TextInput.svelte';
	import {fetchRequest} from '$lib/FetchRequest';
	import Fa             from 'svelte-fa/src/fa.svelte';
	import {faPaperPlane}  from
		'@fortawesome/free-solid-svg-icons/faPaperPlane';
	import {_}            from 'svelte-i18n';
	import {onMount}      from 'svelte';

	export let newOne : bool;
	export let id : number;

	const
		{statusMessageFormatter} = StatusMessage;
	let
		name: string = newOne ? "" : "...",
		number: string = newOne ? "" : "...",
		loading: bool = !newOne,
		status: StatusMessageInfo;
	const updateAccount = async ()=>{
		loading = true;
		const formData = new FormData();
		if (newOne)
			formData.append("id", id);
		formData.append("account_name", name);
		formData.append("account_number", number);
		const path = "ledger/accounts/" + (
			newOne ?
				"create" :
				`${id}/update`
		);
		const {res, json} = await fetchRequest(
			"POST", path, formData, true, false
		);
		if (!res.ok) {
			status = statusMessageFormatter(res, json);
			loading = true;
			return;
		}
		window.location.href = "/accounts";
		loading = false;
	};
	onMount(async ()=>{
		if (newOne)
			return;
		const {res, json} = await fetchRequest("GET", `ledger/accounts`);
		if (!res.ok) {
			status = statusMessageFormatter(res, json);
			return;
		}
		const accounts = json.results;
		const account = accounts.filter(x => +x.id === +id)[0];
		name = account.account_name;
		number = account.account_number;
		loading = false;
	});
</script>
<Loader bind:loading>
	<form
		on:submit|preventDefault={updateAccount}
		class="
			flex mt-6 mb-6 absolute left-1/2 -translate-x-1/2 items-start
			justify-center gap-8 md:mt-8 w-[1500px]
		"
	>
		<div class="bg-white p-6 shadow-xl flex flex-col gap-6 md:w-2/5">
			<h1 class="text-2xl">{newOne ? "Add an" : "Update"} Account</h1>
			<TextInput label="Name" bind:value={name} required/>
			<TextInput label="Number" bind:value={number} required/>
			<StatusMessage bind:status/>
			<Button type="submit" disabled={loading}>
				<div class="flex justify-center gap-3 items-center">
					<Fa icon={faPaperPlane}/>
					{$_(newOne ? "Add Account" : "Update Account")}
				</div>
			</Button>
		</div>
	</form>
</Loader>
