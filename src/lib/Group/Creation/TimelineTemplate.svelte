<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';

	export let area_vote_time_delta: number,
		proposal_time_delta: number,
		prediction_statement_time_delta: number,
		prediction_bet_time_delta: number,
		delegate_vote_time_delta: number,
		vote_time_delta: number,
        end_time_delta:number,
		poll_type: 3 | 4;

	let name: string;

	const templateList = async () => {
		const groupId = $page.url.searchParams.get('id');
        console.log(groupId, "HEI");
        
		const { res, json } = await fetchRequest('GET', `group/${groupId}/poll/template/list`);

		if (!res.ok) return;
	};

	const templateCreate = async () => {
		const groupId = $page.url.searchParams.get('id');
		const { res, json } = await fetchRequest('POST', `group/${groupId}/poll/template/create`, {
			area_vote_time_delta,
			proposal_time_delta,
			prediction_statement_time_delta,
			prediction_bet_time_delta,
			delegate_vote_time_delta,
			vote_time_delta,
			end_time_delta,
			poll_type,
			name,
			poll_is_dynamic: false
		});

		if (!res.ok) return;
	};

	onMount(() => {
		templateList();
	});
</script>

<form on:submit|preventDefault={templateCreate}>
	<TextInput label="name" required bind:value={name} />
	<Button type="submit">Save Timetemplate</Button>
</form>
