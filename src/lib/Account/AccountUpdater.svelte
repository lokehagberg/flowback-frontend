<script lang="ts">
	import {onMount}        from 'svelte';
	import {_}              from 'svelte-i18n';
	import Fa               from 'svelte-fa/src/fa.svelte';
	import {faPaperPlane}   from
		'@fortawesome/free-solid-svg-icons/faPaperPlane';
	import Button           from '$lib/Generic/Button.svelte';
	import Loader           from '$lib/Generic/Loader.svelte';
	import TextInput        from '$lib/Generic/TextInput.svelte';
	import type {StatusMessageInfo} from '$lib/Generic/GenericFunctions';
	import StatusMessage    from '$lib/Generic/StatusMessage.svelte';
	import {accountsStore}  from '$lib/Account/stores';
	import {fetchRequest}   from '$lib/FetchRequest';

	export let
		newOne: bool,
		id: number;
	let
		name: string = newOne ? "" : "...",
		number: string = newOne ? "" : "...",
		status: StatuMessageInfo,
		loading: bool = !newOne;
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
			status = StatusMessage.statusMessageFormatter(res, json);
			loading = true;
			return;
		}
		await accountsStore.load();
		window.location.href = "/accounts";
		loading = false;
	};
	onMount(async ()=>{
		if (newOne)
			return;
		const accounts = await accountsStore.get();
		const account = accounts.filter(x => +x.id === +id)[0];
		name = account.account_name;
		number = account.account_number;
		status = accounts.status;
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
			<StatusMessage bind:status disableSuccess={true}/>
			<Button type="submit" disabled={loading}>
				<div class="flex justify-center gap-3 items-center">
					<Fa icon={faPaperPlane}/>
					{$_((newOne ? "Add" : "Update") + " Account")}
				</div>
			</Button>
		</div>
	</form>
</Loader>
