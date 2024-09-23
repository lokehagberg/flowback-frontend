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
	import { createPoll as createPollBlockchain } from '$lib/Blockchain/javascript/pollsBlockchain';
	import FileUploads from '$lib/Generic/FileUploads.svelte';
	import type { pollType, template } from './interface';
	import AdvancedTimeSettings from './AdvancedTimeSettings.svelte';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';
	import Tab from '$lib/Generic/Tab.svelte';
	import {
		createCalendar,
		createViewDay,
		createViewWeek,
		createViewMonthGrid,
		createViewMonthAgenda
	} from '@schedule-x/calendar';
	import '@schedule-x/theme-default/dist/index.css';
	import { env } from '$env/dynamic/public';
	import { ScheduleXCalendar } from '@schedule-x/svelte';
	import Schedule from '$lib/Schedule/Schedule.svelte';
	import MonthView from '$lib/Generic/Schedules/MonthView.svelte';

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
		selectedPage: 'poll' | 'thread' = 'poll';

	const groupId = $page.url.searchParams.get('id');

	$: (daysBetweenPhases || !daysBetweenPhases) && changeDaysBetweenPhases();

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
		formData.append('tag', '1');

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
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.url.searchParams.get('id')}/thread/create`,
			{
				title,
				description
			}
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
</script>

<form
	on:submit|preventDefault={() => (selectedPage === 'poll' ? createPoll() : createThread())}
	class="md:w-2/3 max-w-[800px]"
>
	<Loader {loading}>
		<div class="bg-white dark:bg-darkobject p-6 shadow-xl flex flex-col gap-3 rounded">
			<Tab displayNames={['Poll', 'Thread']} tabs={['poll', 'thread']} bind:selectedPage />
			{#if selectedPage === 'poll'}
				<h1 class="text-2xl">{$_('Create a Poll')}</h1>
				<RadioButtons2
					name="poll Content"
					label="Poll Content"
					ClassInner="inline mr-2"
					labels={['Text Poll', 'Date Poll']}
					values={['Text Poll', 'Date Poll']}
					bind:value={selected_poll}
				/>
			{:else if selectedPage === 'thread'}
				<h1 class="text-2xl">{$_('Create a Thread')}</h1>
			{/if}
			<TextInput required label="Title" bind:value={title} />
			<TextArea label="Description" bind:value={description} />

			<FileUploads bind:images />
			<!-- Time setup -->
			{#if selectedPage === 'poll'}
				<div class="border border-gray-200 dark:border-gray-500 p-6">
					<div>
						<h2 class="">{$_('Days between phases')}</h2>
						<input
							type="number"
							class="dark:bg-darkbackground show-buttons-all-times"
							bind:value={daysBetweenPhases}
							min="0"
							max="1000"
						/>
					</div>

					<Button
						Class={`!bg-blue-600 mt-4 !block`}
						action={() => (advancedTimeSettings = !advancedTimeSettings)}
						buttonStyle="secondary">{$_('Advanced time settings')}</Button
					>

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
					/>
				</div>
			{/if}
			<!-- <Schedule type="pollcreation"/> -->

			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<RadioButtons bind:Yes={isPublic} label="Public?" />
			{/if}

			{#if selectedPage === 'poll'}
				<RadioButtons bind:Yes={isFF} label="Fast Foward?" />
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

<!-- <ScheduleXCalendar {calendarApp} monthGridEvent={T} /> -->

<!-- <MonthView
	bind:start_date
	bind:area_vote_end_date
	bind:proposal_end_date
	bind:prediction_statement_end_date
	bind:prediction_bet_end_date
	bind:delegate_vote_end_date
	bind:vote_end_date
	bind:end_date
/> -->
