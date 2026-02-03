<script lang="ts">
	import Select from '$lib/Generic/Select.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import type { proposal } from '$lib/Poll/interface';
	import { _ } from 'svelte-i18n';
	import { commentsStore, filterByTags } from './commentStore';
	import Modal from '$lib/Generic/Modal.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { page } from '$app/stores';
	import { idfy } from '$lib/Generic/GenericFunctions2';

	export let sortBy: string | null = null,
		Class = '',
		searchString: string = '',
		proposals: proposal[] = [],
		selectedProposals: number[] = [];

	let displayProposalsModal = false;

	$: if (selectedProposals.length === 0)
		commentsStore.update((store) => ({
			allComments: store.allComments,
			filterByProposal: null,
			filteredComments: store.allComments
		}));
	else {
		filterByTags(proposals, selectedProposals, $page.params.pollId ?? '');
	}
</script>

<div class={Class}>
	<div class="">
		<TextInput
			label={''}
			search={true}
			max={null}
			Class="w-[100rem]"
			inputClass="placeholder-gray-600 pl-8 pr-6 text-gray-500 border-0 bg-gray-100 dark:bg-darkobject"
			bind:value={searchString}
			placeholder={$_('Search comments')}
		/>
	</div>

	<div class="w-auto max-w-xs flex flex-row items-center dark:text-darkmodeText">
		<p class="pr-2">{$_('Sort')}:</p>
		<Select
			innerLabel={null}
			values={[
				'created_at_asc',
				'created_at_desc',
				// 'total_replies_asc',
				// 'total_replies_desc',
				'score_asc',
				'score_desc',
				null
			]}
			bind:value={sortBy}
			labels={[$_('Recent'), $_('Oldest'), $_('Top'), $_('Controversial'), $_('Hot')]}
			Class="border-0 font-semibold"
		/>

		{#if proposals?.length > 0}
			<Button onClick={() => (displayProposalsModal = true)} Class="ml-2"
				>{$_('Filter by Proposal')}</Button
			>
		{/if}
	</div>
</div>

{#if proposals}
	<Modal bind:open={displayProposalsModal}>
		<div slot="body">
			<!-- Being able to select arbitrary numbers of proposals to filter on -->
			{#each proposals as proposal}
				<div class="flex items-center gap-2 mt-4">
					<input
						type="checkbox"
						name="proposals"
						id={`${idfy(proposal.title)}`}
						value={proposal.id}
						bind:group={selectedProposals}
					/>
					<!-- on:input={filterByTags} -->
					<label class="text-left" for={`proposal-${proposal.id}`}>{proposal.title}</label>
				</div>
			{/each}
		</div>
	</Modal>
{/if}
