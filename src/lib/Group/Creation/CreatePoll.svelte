<script lang="ts">
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Tag from '$lib/Group/Tag.svelte';
	import { onMount } from 'svelte';
	import type { Tag as TagType } from '$lib/Group/interface';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { DateInput } from 'date-picker-svelte';
	import { _ } from 'svelte-i18n';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	//@ts-ignore
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faArrowUp } from '@fortawesome/free-solid-svg-icons/faArrowUp';
	import { faArrowDown } from '@fortawesome/free-solid-svg-icons/faArrowDown';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faCheck } from '@fortawesome/free-solid-svg-icons/faCheck';
	import { faWallet } from '@fortawesome/free-solid-svg-icons/faWallet';
	import { faSliders } from '@fortawesome/free-solid-svg-icons/faSliders';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { faAlignLeft } from '@fortawesome/free-solid-svg-icons/faAlignLeft';
	import { faHourglass } from '@fortawesome/free-solid-svg-icons/faHourglass';
	import { faClockRotateLeft } from '@fortawesome/free-solid-svg-icons/faClockRotateLeft';
	import Loader from '$lib/Generic/Loader.svelte';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { tagsCreatePoll as tagsCreatePollLimit } from '$lib/Generic/APILimits.json';
	import { maxDatePickerYear } from '$lib/Generic/DateFormatter';
	import ImageUpload from '$lib/Generic/ImageUpload.svelte';
	import { faUser } from '@fortawesome/free-solid-svg-icons/faUser';
	import Select from '$lib/Generic/Select.svelte';
	import { faTachographDigital } from '@fortawesome/free-solid-svg-icons';

	type polltypes =
		| 'Ranking'
		| 'For/Against'
		| 'Quadratic'
		| 'Cardinal'
		| 'Scheduled'
		| 'Text Poll'
		| 'Date Poll';
	type timetypes = 'Endtime' | 'Dynamic';

	let selected_poll: polltypes = 'Text Poll';
	let selected_time: timetypes = 'Endtime';
	//Something about this feels very scuffed
	const polls: polltypes[] = ['Text Poll', 'Date Poll'];
	const times: timetypes[] = [];

	const pollDescriptions: Record<polltypes, string> = {
		'Text Poll': '',
		'Date Poll': '',
		Ranking: `Ranking is the method of preferential voting known as the borda count. The top proposal in Added always gets the number of points as there are proposals (it does not depend on there being proposals below it), and the one below that gets that number minus one, the one below that gets that number minus two and so on. Each proposal that are in abstain each get zero points. This is added over all voters and is divided by the total number of votes to get the result.`,
		'For/Against': `For/Against is the method where each proposal that is voted for gets one point and each voted against gets minus one independently of order, all other proposals get zero points. The points are then added over all voters and is divided by the total number of votes to get the result.`,
		Cardinal: `Cardinal currently has no description`,
		Quadratic: `Quadratic is the method where each member can rank by writing any number for all polls, which are ranked accordingly and get the percentage compared to the total that the member gives, the percentages are added up over all members and divided by the total to get the result. This means that not only are the proposals ranked by order of preference, but the degree by which one proposal is better than another is reflected. Totals will not exceed 10^6.`,
		Scheduled: `Scheduled is the method where dates and times are voted on to decide meetings or events for the members of the group. Time polls are always Private and can only be seen by group members. One can only vote for a time or vote to drop the proposal, a default proposal for every time poll. This is carried out by the ranking method.`
	};

	const timeDescriptions: Record<timetypes, string> = {
		Endtime: `An poll with an end date has a specified time when the poll finishes and results are displayed.`,
		Dynamic: `A dynamic poll is always on and lacks an end date, results are always on display as they change dynamically.`
	};

	const disabled: (polltypes | timetypes)[] = ['For/Against', 'Cardinal', 'Quadratic', 'Dynamic'];

	const pollIcons: Record<polltypes, any[]> = {
		'Text Poll': [faAlignLeft],
		'Date Poll': [faCalendarAlt],
		Ranking: [faArrowUp, faArrowDown],
		'For/Against': [faCheck, faX],
		Cardinal: [faSliders],
		Quadratic: [faWallet],
		Scheduled: [faCalendarAlt]
	};

	const timeIcons: Record<timetypes, any[]> = {
		Endtime: [faHourglass],
		Dynamic: [faClockRotateLeft]
	};

	let title = '',
		description = '',
		tags: TagType[] = [],
		defaultType: polltypes = 'Text Poll',
		selectedTag: TagType,
		status: StatusMessageInfo,
		start_date = new Date(),
		area_vote_end_date = new Date(),
		proposal_end_date = new Date(),
		prediction_statement_end_date = new Date(),
		prediction_bet_end_date = new Date(),
		delegate_vote_end_date = new Date(),
		vote_end_date = new Date(),
		end_date = new Date(),
		isPublic = false,
		loading = false,
		advancedTimeSettings = false,
		daysBetweenPhases = 1,
		image: File;

	const groupId = $page.url.searchParams.get('id');

	const createPoll = async () => {
		if (selectedTag === undefined) {
			status = { message: 'Must select tag', success: false };
			return;
		}

		console.log(selectedTag);

		const formData = new FormData();
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
		formData.append('poll_type', (selected_poll === defaultType ? 4 : 3).toString());
		formData.append('tag', selectedTag.id.toString());
		formData.append('dynamic', selected_poll === defaultType ? 'false' : 'true');
		formData.append('public', isPublic.toString());
		formData.append('pinned', 'false');
		if (image) formData.append('attachments', image);

		loading = true;
		const { res, json } = await fetchRequest(
			'POST',
			`group/${groupId}/poll/create`,
			formData,
			true,
			false
		);

		loading = false;
		status = statusMessageFormatter(res, json);

		if (res.ok) window.location.href = `groups/${groupId}/polls/${json}`;
	};

	const getGroupTags = async () => {
		loading = true;
		const { json } = await fetchRequest(
			'GET',
			`group/${groupId}/tags?limit=${tagsCreatePollLimit}`
		);
		loading = false;
		tags = json.results;
		selectedTag = tags[0];
	};

	$: (daysBetweenPhases || !daysBetweenPhases) && changeDaysBetweenPhases();

	const changeDaysBetweenPhases = () => {
		const now = new Date();
		start_date = new Date();

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
		console.log($page.params.type, 'TYPPPE');
	});
</script>

<div class="flex flex-col md:flex-row mt-8 gap-6 ml-8 mr-8 lg:w-[900px] dark:text-darkmodeText">
	<form
		on:submit|preventDefault={() =>
			!disabled.includes(selected_poll) && !disabled.includes(selected_time) ? createPoll() : null}
		class="md:w-2/3"
	>
		<Loader {loading}>
			<div class="bg-white dark:bg-darkobject p-6 shadow-xl flex flex-col gap-3 rounded">
				<h1 class="text-2xl">{$_('Create a poll')}</h1>
				<TextInput required label="Title" bind:value={title} />
				<TextArea required label="Description" bind:value={description} />
				<div class="border border-gray-200 dark:border-gray-500 p-6">
					<Button
						Class={`inline !bg-blue-600`}
						action={() => (advancedTimeSettings = !advancedTimeSettings)}
						>{$_('Advanced time settings')}</Button
					>
					<h2 class="mt-4">{$_('Days between phases')}</h2>
					<input
						type="number"
						class="dark:bg-darkbackground"
						bind:value={daysBetweenPhases}
						min="0"
						max="1000"
					/>

					{#if advancedTimeSettings}
						<div class="grid grid-cols-2 gap-6 justify-center">
							<div>
								<h2 class="mt-4">{$_('Poll start')}</h2>
								<DateInput
									format="yyyy-MM-dd HH:mm"
									closeOnSelection
									bind:value={start_date}
									min={new Date()}
									max={maxDatePickerYear}
								/>
							</div>
							{#if selected_poll !== 'Date Poll'}
								<div>
									<h2 class="mt-4">{$_('Area voting end')}</h2>
									<DateInput
										format="yyyy-MM-dd HH:mm"
										closeOnSelection
										bind:value={area_vote_end_date}
										min={start_date}
										max={maxDatePickerYear}
									/>
								</div>
							{/if}
							<div>
								<h2 class="mt-4">{$_('Proposal end')}</h2>
								<DateInput
									format="yyyy-MM-dd HH:mm"
									closeOnSelection
									bind:value={proposal_end_date}
									min={area_vote_end_date}
									max={maxDatePickerYear}
								/>
							</div>
							{#if selected_poll !== 'Date Poll'}
								<div>
									<h2 class="mt-4">{$_('Prediction statement end')}</h2>
									<DateInput
										format="yyyy-MM-dd HH:mm"
										closeOnSelection
										bind:value={prediction_statement_end_date}
										min={proposal_end_date}
										max={maxDatePickerYear}
									/>
								</div>
								<div>
									<h2 class="mt-4">{$_('Prediction bet end')}</h2>
									<DateInput
										format="yyyy-MM-dd HH:mm"
										closeOnSelection
										bind:value={prediction_bet_end_date}
										min={prediction_statement_end_date}
										max={maxDatePickerYear}
									/>
								</div>
								<div>
									<h2 class="mt-4">{$_('Delegate Voting end date')}</h2>
									<DateInput
										format="yyyy-MM-dd HH:mm"
										closeOnSelection
										bind:value={delegate_vote_end_date}
										min={prediction_bet_end_date}
										max={maxDatePickerYear}
									/>
								</div>
							{/if}
							<div>
								<h2 class="mt-4">{$_('Voting end date')}</h2>
								<DateInput
									format="yyyy-MM-dd HH:mm"
									closeOnSelection
									bind:value={vote_end_date}
									min={delegate_vote_end_date}
									max={maxDatePickerYear}
								/>
							</div>
							<div>
								<h2 class="mt-4">{$_('End date')}</h2>
								<DateInput
									format="yyyy-MM-dd HH:mm"
									closeOnSelection
									bind:value={end_date}
									min={vote_end_date}
									max={maxDatePickerYear}
								/>
							</div>
						</div>
					{/if}
				</div>
				<!-- <h2>{$_('Select Tag')}</h2>
				<div class="flex gap-4 flex-wrap">
					{#each tags as tag}
						<Tag
							onclick={() => (selectedTag = tag)}
							tag={{ name: tag.name, id: tag.id, active: true }}
							Class={`cursor-pointer ${
								selectedTag === tag ? 'bg-gray-500' : 'bg-gray-300 text-gray-500'
							}`}
						/>
					{/each}
				</div> -->
				<RadioButtons bind:Yes={isPublic} label="Public?" />
				{#if disabled.includes(selected_poll) || disabled.includes(selected_time)}
					{$_('This polltype is not implemented yet')}
				{/if}
				<StatusMessage bind:status />
				<Button
					type="submit"
					disabled={loading || disabled.includes(selected_poll) || disabled.includes(selected_time)}
					Class={disabled.includes(selected_poll) || disabled.includes(selected_time)
						? '!bg-gray-200'
						: 'bg-primary'}>{$_('Create Poll')}</Button
				>
				<ImageUpload
					icon={faUser}
					bind:image
					label=""
					iconSize="2x"
					Class="flex !flex-row-reverse"
				/>
			</div>
		</Loader>
	</form>
	<div class="md:w-1/3">
		<div class="bg-white dark:bg-darkobject p-6 shadow-xl rounded">
			<div class="flex flex-col gap-6">
				{#each polls as poll}
					<Button
						disabled={loading}
						action={() => (selected_poll = poll)}
						buttonStyle={(() => {
							if (selected_poll === poll) return poll === 'Text Poll' ? 'primary' : 'accent';
							else return poll === 'Text Poll' ? 'secondary' : 'accent-secondary';
						})()}
						Class={`${selected_poll === poll ? 'shadow-sm outline outline-0' : 'shadow-xl'}
							`}
					>
						<div class="flex items-center text-center">
							<!-- Some buttons have multiple icons -->
							{#each pollIcons[poll] as icon}
								<Fa {icon} />
							{/each}

							<span class="ml-10">{$_(poll)}</span>
						</div>
					</Button>
				{/each}
			</div>
			<div class="flex flex-col gap-6 mt--12">
				{#each times as time}
					<Button
						disabled={loading}
						Class={`${
							disabled.includes(time) && (selected_time === time ? '!bg-gray-400' : '!bg-gray-200')
						} ${selected_time === time ? 'bg-purple-600' : 'bg-purple-300'}`}
						action={() => (selected_time = time)}
					>
						<div class="flex items-center text-center">
							{#each timeIcons[time] as icon}
								<Fa {icon} />
							{/each}
							<span class="ml-10">{$_(time)}</span>
						</div>
					</Button>
				{/each}
			</div>
		</div>
		<!-- <div class="bg-white p-6 shadow-xl mt-4 rounded">
				<div>
					{#each Object.entries(pollDescriptions) as [pollType, description]}
						{#if selected_poll === pollType}
							{$_(description)}
						{/if}
					{/each}
				</div>
				<div class="mt-6">
					{#each Object.entries(timeDescriptions) as [timeType, description]}
						{#if selected_time === timeType}
							{$_(description)}
						{/if}
					{/each}
				</div>
			</div> -->
	</div>
</div>
