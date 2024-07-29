<script lang="ts">
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faBars } from '@fortawesome/free-solid-svg-icons/faBars';
	import type { proposal } from './interface';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { groupUser } from '$lib/Group/interface';
	import { faPen } from '@fortawesome/free-solid-svg-icons/faPen';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { _ } from 'svelte-i18n';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { onMount } from 'svelte';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import { checkForLinks } from '$lib/Generic/GenericFunctions';

	export let proposal: proposal,
		Class = '',
		groupUser: groupUser,
		proposals: proposal[],
		editable: boolean = false;

	export const id: number = 0;

	let isHoveredOver = false,
		newTitle = proposal.title,
		newDescription = proposal.description,
		open = false,
		show = false;

	const deleteProposal = async () => {
		const { res, json } = await fetchRequest('POST', `group/poll/proposal/${proposal.id}/delete`);
		if (!res.ok) return;
		proposals = proposals.filter((proposalInList) => proposalInList.id !== proposal.id);
		proposals = proposals;
		show = true;
	};

	//TODO: Actual Edit
	const editProposal = async () => {
		await deleteProposal();

		let newProposal = proposal;
		newProposal.title = newTitle;
		newProposal.description = newDescription;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/proposal/create`,
			newProposal
		);

		if (!res.ok) return;

		proposals.push({ ...newProposal, title: newTitle, description: newDescription });
		proposals = proposals;
		proposal.title = newTitle;
		proposal.description = newDescription;
		show = true;
	};

	onMount(() => {
		checkForLinks(proposal.description, `proposal-${proposal.id}-description`);
	});
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	class={`select-none dark:bg-darkobject hover:shadow-2xl proposal flex justify-between items-center bg-white gap-8 p-4 border border-gray-200 dark:border-gray-500 lg:h-36 xl:h-40 ${Class}`}
	on:dragenter|preventDefault={() => (isHoveredOver = true)}
	on:dragleave|preventDefault={() => (isHoveredOver = false)}
	class:hidden={isHoveredOver}
>
	<div><Fa icon={faBars} /></div>
	<div class="h-full w-2/3">
		<h1 class="text-lg text-left">{proposal.title}</h1>
		<p class="elipsis text-sm mt-2" id={`proposal-${proposal.id}-description`}>
			{proposal.description}
		</p>
	</div>
	<input id="amount" class="dark:bg-darkobject" type="number" min={0} />
	
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	{#if editable}
		<!-- TODO and also before proposal end date -->
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div on:click={() => (open = true)} class="cursor-pointer" on:keydown>
			<Fa icon={faPen} />
		</div>
		<div on:click={deleteProposal} class="cursor-pointer" on:keydown>
			<Fa icon={faX} />
		</div>
	{/if}
	<slot />
</div>

<Modal bind:open>
	<span slot="header">{$_('Edit proposal')}</span>
	<div slot="body">
		<form
			on:submit|preventDefault={() => {
				open = false;
				editProposal();
			}}
		>
			<TextInput label="Title" bind:value={newTitle} />
			<TextArea label="Description" bind:value={newDescription} />
			<Button type="submit">{$_('Submit')}</Button>
		</form>
	</div>
	<div slot="footer" />
</Modal>

<SuccessPoppup bind:show message="Successfully edited proposal" />

<style>
	.elipsis {
		text-overflow: ellipsis;
		overflow: hidden;
		/* // Addition lines for 2 line or multiline ellipsis */
		display: -webkit-box !important;
		-webkit-line-clamp: 2;
		-webkit-box-orient: vertical;
		white-space: normal;
	}

	.proposal {
		transition: box-shadow 0.15s ease-in;
	}
</style>
