<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import type { template } from './interface';
	import { _ } from 'svelte-i18n';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';

	export let area_vote_time_delta: number,
		proposal_time_delta: number,
		prediction_statement_time_delta: number,
		prediction_bet_time_delta: number,
		delegate_vote_time_delta: number,
		vote_time_delta: number,
		end_time_delta: number,
		poll_type: 3 | 4,
		handleSelectTemplate = (template: template) => {};

	let name: string,
		templates: template[] = [],
		poppup: poppup;

	const templateList = async () => {
		const groupId = $page.url.searchParams.get('id');

		const { res, json } = await fetchRequest('GET', `group/${groupId}/poll/template/list`);

		if (!res.ok) {
			poppup = { message: 'Could not get templates', success: false };
			return;
		}

		templates = json.results;
	};

	const templateCreate = async () => {
		const groupId = $page.url.searchParams.get('id');
		const template = {
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
		};

		const { res, json } = await fetchRequest(
			'POST',
			`group/${groupId}/poll/template/create`,
			template
		);

		if (!res.ok) {
			poppup = { message: 'Could not create template', success: false };
			return;
		}

		templates.push(template);
		templates = templates;
		poppup = { message: 'Successfully saved timetemplate', success: true };
	};

	onMount(() => {
		templateList();
	});
</script>

<form class="mt-2" on:submit|preventDefault={templateCreate}>
	<TextInput label="Name" required bind:value={name} />
	<Button Class="mt-2" type="submit">{$_('Save Timetemplate')}</Button>
</form>

{#each templates as template}
	<button class="block" on:click={() => handleSelectTemplate(template)} type="button">
		{template.name}
	</button>
{/each}

<Poppup bind:poppup />
