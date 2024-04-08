<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { faCheck, faCross, faX } from '@fortawesome/free-solid-svg-icons';
	import { DateInput } from 'date-picker-svelte';
	import Fa from 'svelte-fa';
	import { page } from '$app/stores';

	let open = false,
		date: Date;

	let postProposal = async () => {
		const { res, json } = await fetchRequest('POST', `group/poll/${$page.params.pollId}/post`, {
			date
		});
	};
</script>

<div class="w-[80px]">
	<div class="text-center">SUN</div>
	<div class="font-bold text-center">6</div>
	<div class="text-center">12:00</div>

	<div class="flex flex-col items-center rounded-none">
		<Button Class="flex justify-center w-[90%] rounded-none"><Fa icon={faCheck} /></Button>
		<Button Class="flex justify-center w-[90%] rounded-none" buttonStyle="secondary"><Fa icon={faX} /></Button>
	</div>
</div>

<Button action={() => (open = true)}>Create Proposal</Button>

<Modal bind:open onSubmit={postProposal}>
	<div slot="body">
		<DateInput bind:value={date} />
	</div>
	<div slot="footer">
		<Button type="submit">Submit</Button>
	</div>
</Modal>
