<script lang="ts">
	import Button         from '$lib/Generic/Button.svelte';
	import {fetchRequest} from '$lib/FetchRequest';
	import type {Account} from '$lib/Group/interface';
	import {_}            from 'svelte-i18n';
	export let account : Account;
	const update = async ()=>{
		window.location.href = `/accounts/${account.id}/update`;
	};
	const remove = async ()=>{
	};
</script>
<div
	class="
		bg-white relative
		shadow-md hover:shadow-xl transition-shadow
		rounded-2xl
	"
>
	<div>
		<h2 class="text-2xl p-4 mt-10 text-center">
			{account.account_name}
		</h2>
		<p class="pl-6 pr-6 pb-6 break-words">
			<code>{account.account_number}</code>: {account.balance}
			<br/>
			<a href="/accounts/{account.id}/transactions">Transactions</a>
		</p>
		<Button action={update}>{$_("Update")}</Button>
		<Button action={remove} buttonStyle="warning">Remove</Button>
		<br/>&nbsp;
	</div>
</div>
