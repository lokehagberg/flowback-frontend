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
	import Fa from 'svelte-fa';
	import { faTrash, faEdit } from '@fortawesome/free-solid-svg-icons';

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
		poppup: poppup,
		isUpdating: boolean = false,
		currentTemplateId: number | null = null;

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

		templates = [...templates, json];
		poppup = { message: 'Successfully saved timetemplate', success: true };
		await templateList();

		name = '';
	};

	const templateDelete = async (template_id: number) => {
		const { res } = await fetchRequest(
			'POST',
			`group/poll/template/${template_id}/delete`
		);

		if (!res.ok) {
			poppup = { message: 'Could not delete template', success: false };
			return;
		}

		templates = templates.filter(template => template.id !== template_id);
		poppup = { message: 'Template deleted successfully', success: true };
	};

	//TODO: Fix a better templateUpdate using Update-API instead of Delete+Create
	const templateUpdate = async () => {
		if (!currentTemplateId) return;

		const oldName = name;

		await templateDelete(currentTemplateId);
		setTimeout(async () => {
			name = oldName;
			await templateCreate();
		}, 100); 

		isUpdating = false;
		currentTemplateId = null;
	};

	const prepareUpdateTemplate = (template: template) => {
		name = template.name;
		currentTemplateId = template.id;
		isUpdating = true;
	};

	const cancelUpdate = () => {
		isUpdating = false;
		currentTemplateId = null;
		name = '';
	};

	onMount(() => {
		templateList();
	});
</script>

<form class="mt-2" on:submit|preventDefault={isUpdating ? templateUpdate : templateCreate}>
	<TextInput label="Name" max={50} required bind:value={name} />
	<Button Class="mt-2" type="submit">
		{#if isUpdating}
			{$_('Update')}
		{:else}
			{$_('Save Timetemplate')}
		{/if}
	</Button>
	{#if isUpdating}
		<Button Class="mt-2 ml-2" buttonStyle="warning" type="button" onClick={cancelUpdate}>
			{$_('Cancel')}
		</Button>
	{/if}
</form>

<div class="m-4 grid grid-cols-2 gap-2 gap-x-4">
	{#each templates as template (template.id)}
		<div class="flex items-center justify-between gap-2 p-2 rounded hover:bg-gray-100">
			<button class="block break-words whitespace-normal overflow-hidden" on:click={() => handleSelectTemplate(template)} type="button">
				{template.name}
			</button>

			<div class="flex gap-2">
				<Button Class="ml-2 !border-none" buttonStyle="primary-light"
					onClick={() => {
						handleSelectTemplate(template);
						prepareUpdateTemplate(template);}}>
					<Fa class="text-lg" icon={faEdit} />
				</Button>
				<Button onClick={() => templateDelete(template.id)} Class="p-2 text-lg cursor-pointer bg-white">
					<Fa class="text-red-500" icon={faTrash} />
				</Button>
			</div>
		</div>
	{/each}
</div>

<Poppup bind:poppup />
