<script lang="ts">
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { _ } from 'svelte-i18n';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Loader from '$lib/Generic/Loader.svelte';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { goto } from '$app/navigation';
	import { createPoll as createPollBlockchain } from '$lib/Blockchain_v1_Ethereum/javascript/pollsBlockchain';
	import FileUploads from '$lib/Generic/FileUploads.svelte';
	import type { pollType, template } from './interface';
	import AdvancedTimeSettings from './AdvancedTimeSettings.svelte';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';
	import Tab from '$lib/Generic/Tab.svelte';
	import { env } from '$env/dynamic/public';
	import {
		faAlignLeft,
		faArrowLeft,
		faCalendarAlt,
		faChevronDown
	} from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { onMount } from 'svelte';

	let title = '',
		description = '',
		status: StatusMessageInfo,
		start_date = new Date(),
		area_vote_end_date = new Date(),
		proposal_end_date = new Date(),
		prediction_statement_end_date = new Date(),
		prediction_bet_end_date = new Date(),
		delegate_vote_end_date = new Date(),
		vote_end_date = new Date(),
		end_date = new Date(),
		isPublic = true,
		loading = false,
		advancedTimeSettings = false,
		daysBetweenPhases = 1,
		images: File[],
		isFF = true,
		pushToBlockchain = true,
		selected_poll: pollType = 'Text Poll',
		selectedPage: 'poll' | 'thread' =
			$page.url.searchParams.get('type') === 'thread' ? 'thread' : 'poll',
		tags: { id: number }[] = [];

	const groupId = $page.url.searchParams.get('id');

	$: (daysBetweenPhases || !daysBetweenPhases) && changeDaysBetweenPhases();

	const goBack = () => {
		const groupId = $page.url.searchParams.get('id');
		goto(`/groups/${groupId}`);
	};

	const getGroupTags = async () => {
		const { res, json } = await fetchRequest('GET', `group/${groupId}/tags`);
		if (res.ok) {
			tags = json.results;
		}
	};

	const createPoll = async () => {
		loading = true;
		const formData = new FormData();
		let blockchain_id;

		if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE' && pushToBlockchain) {
			blockchain_id = await createPollBlockchain(Number(groupId), title);
			if (blockchain_id) formData.append('blockchain_id', blockchain_id.toString());
		}

		formData.append('title', title);
		formData.append('description', description);
		formData.append('start_date', start_date.toISOString());
		formData.append('area_vote_end_date', area_vote_end_date.toISOString());
		formData.append('proposal_end_date', proposal_end_date.toISOString());
		formData.append('prediction_statement_end_date', prediction_statement_end_date.toISOString());
		formData.append('prediction_bet_end_date', prediction_bet_end_date.toISOString());
		formData.append('delegate_vote_end_date', delegate_vote_end_date.toISOString());
		formData.append('vote_end_date', vote_end_date.toISOString());
		formData.append('end_date', end_date.toISOString());
		formData.append('allow_fast_forward', isFF.toString());
		formData.append('poll_type', (selected_poll === 'Text Poll' ? 4 : 3).toString());
		formData.append('dynamic', selected_poll === 'Text Poll' ? 'false' : 'true');
		formData.append('public', isPublic.toString());
		formData.append('pinned', 'false');
		formData.append('tag', tags[0]?.id?.toString() || '1');

		images.forEach((image) => {
			formData.append('attachments', image);
		});

		const { res, json } = await fetchRequest(
			'POST',
			`group/${groupId}/poll/create`,
			formData,
			true,
			false
		);

		loading = false;

		if (!res.ok) status = statusMessageFormatter(res, json);

		if (res.ok && groupId) {
			goto(`groups/${groupId}/polls/${json}`);
		}
	};

	const createThread = async () => {
		let thread: { title: string; description?: string } = { title };
		if (description) thread.description = description;

		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.url.searchParams.get('id')}/thread/create`,
			thread
		);
		if (!res.ok) {
			// poppup = { message: "Couldn't create Thread", success: false };
		}
		if (res.ok) goto(`groups/${$page.url.searchParams.get('id')}/thread/${json}`);
	};

	//TODO: Refactor so arbitrary number of phases can be done
	const changeDaysBetweenPhases = () => {
		const now = new Date();
		start_date = new Date();
		start_date.setHours(0, 0, 0, 0);

		//For debug purposes this puts one minute delay between each phase.
		if (daysBetweenPhases === 0) {
			area_vote_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			proposal_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			prediction_statement_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			prediction_bet_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			delegate_vote_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			vote_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			//For users to select over multiple days
		} else {
			area_vote_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			proposal_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			prediction_statement_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			prediction_bet_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			delegate_vote_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			vote_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
		}
	};

	onMount(() => {
		getGroupTags();
	});

	$: if (selectedPage) status = { message: null, success: false };
</script>

<form
	on:submit|preventDefault={() => (selectedPage === 'poll' ? createPoll() : createThread())}
	class="relative md:w-2/3 max-w-[800px] dark:text-darkmodeText my-6"
>
	<button
		class="absolute -left-10 top-0 z-10 text-gray-600 hover:text-gray-800 dark:text-gray-400 dark:hover:text-gray-200"
		on:click={goBack}
	>
		<Fa icon={faArrowLeft} />
	</button>

	<Loader {loading}>
		<div class="bg-white dark:bg-darkobject p-6 shadow-xl flex flex-col gap-3 rounded">
			<Tab displayNames={['Poll', 'Thread']} tabs={['poll', 'thread']} bind:selectedPage />

			{#if selectedPage === 'poll'}
				<RadioButtons2
					name="poll Content"
					label="Poll Content"
					ClassInner="mr-2 flex gap-2 items-center"
					horizontal
					labels={['Text Poll', 'Date Poll']}
					values={['Text Poll', 'Date Poll']}
					icons={[faAlignLeft, faCalendarAlt]}
					bind:value={selected_poll}
				/>
			{/if}

			<TextInput inputClass="bg-white" required label="Title" bind:value={title} />
			<TextArea label="Description" bind:value={description} />
			<FileUploads bind:images />

			<!-- Time setup -->
			{#if selectedPage === 'poll'}
				<div class="border border-gray-200 dark:border-gray-500 p-2">
					<div class="flex justify-between">
						<h2>{$_('Days between phases')}:</h2>
						<input
							type="number"
							class="dark:bg-darkbackground show-buttons-all-times text-right"
							bind:value={daysBetweenPhases}
							min="0"
							max="1000"
						/>
					</div>

					<!-- <Button
						Class={`!bg-blue-600 mt-4 !block`}
						action={() => (advancedTimeSettings = !advancedTimeSettings)}
						buttonStyle="secondary">{$_('Advanced time settings')}</Button
					> -->

					<button
						class="w-full flex justify-center items-center border-t-2"
						type="button"
						on:click={() => (advancedTimeSettings = !advancedTimeSettings)}
					>
						<Fa icon={faChevronDown} rotate={advancedTimeSettings ? 180 : 0} />
						{#if !advancedTimeSettings}
							<p>{$_('Display advanced time settings')}</p>
						{:else}
							<p>{$_('Hide advanced time settings')}</p>
						{/if}
					</button>

					{#if advancedTimeSettings}
						<AdvancedTimeSettings
							bind:selected_poll
							bind:advancedTimeSettings
							bind:start_date
							bind:area_vote_end_date
							bind:proposal_end_date
							bind:prediction_statement_end_date
							bind:prediction_bet_end_date
							bind:delegate_vote_end_date
							bind:vote_end_date
							bind:end_date
							bind:daysBetweenPhases
						/>
					{/if}
				</div>
			{/if}

			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<RadioButtons bind:Yes={isPublic} label="Public?" />
			{/if}

			{#if selectedPage === 'poll'}
				<RadioButtons bind:Yes={isFF} label="Fast Forward?" />
			{/if}

			{#if env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE'}
				<RadioButtons bind:Yes={pushToBlockchain} label="Push to Blockchain?" />
				<!-- <Button action={() => createPollBlockchain(Number($page.url.searchParams.get('id')), "title")}>Push to Blockchain?</Button> -->
			{/if}

			<StatusMessage bind:status />

			<Button type="submit" disabled={loading} Class={'bg-primary p-3 mt-3'}>{$_('Post')}</Button>
		</div></Loader
	>
</form>

<style>
	.show-buttons-all-times::-webkit-inner-spin-button,
	.show-buttons-all-times::-webkit-outer-spin-button {
		opacity: 1;
	}
</style>
