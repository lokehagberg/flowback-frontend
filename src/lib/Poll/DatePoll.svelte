<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { faCheck, faCross, faX } from '@fortawesome/free-solid-svg-icons';
	import { DateInput } from 'date-picker-svelte';
	import Fa from 'svelte-fa';
	import { page } from '$app/stores';
	import { deepCopy } from 'ethers/lib/utils';
	import Proposal from './Proposal.svelte';
	import { onMount } from 'svelte';

	let open = false,
		date: Date,
		proposals: Proposal[] = [];

	let postProposal = async () => {
		let end_date = new Date(date);
		end_date.setHours(date.getHours() + 1);

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/proposal/create`,
			{
				start_date: date,
				end_date
			}
		);
	};

	let getProposals = async () => {
		const { res, json } = await fetchRequest('GET', `group/poll/${$page.params.pollId}/proposals`);

		proposals = json.results;
	};

	onMount(() => {
		getProposals();
	});
</script>

<div class="flex">
	{#each proposals as proposal}
		<div class="flex flex-col p-2">
			<div class="text-center">{new Date(proposal.start_date).getDay()}</div>
			<div class="font-bold text-center">
				{new Date(proposal.start_date).getFullYear()}-{new Date(
					proposal.start_date
				).getMonth()}-{new Date(proposal.start_date).getDate()}
			</div>
			<div class="text-center">
				{new Date(proposal.start_date).getHours()}:{new Date(proposal.start_date).getMinutes()}
			</div>

			<div class="flex flex-col items-center rounded-none">
				<Button Class="flex justify-center w-[90%] rounded-none"><Fa icon={faCheck} /></Button>
				<Button Class="flex justify-center w-[90%] rounded-none" buttonStyle="secondary"
					><Fa icon={faX} /></Button
				>
			</div>
		</div>
	{/each}
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
