<script lang="ts">
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
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
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faArrowUp } from '@fortawesome/free-solid-svg-icons/faArrowUp';
	import { faArrowDown } from '@fortawesome/free-solid-svg-icons/faArrowDown';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faCheck } from '@fortawesome/free-solid-svg-icons/faCheck';
	import { faWallet } from '@fortawesome/free-solid-svg-icons/faWallet';
	import { faSliders } from '@fortawesome/free-solid-svg-icons/faSliders';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { faHourglass } from '@fortawesome/free-solid-svg-icons/faHourglass';
	import { faClockRotateLeft } from '@fortawesome/free-solid-svg-icons/faClockRotateLeft';
	import Loader from '$lib/Generic/Loader.svelte';

	type polltypes = 'Ranking' | 'For/Against' | 'Quadratic' | 'Cardinal' | 'Scheduled';
	type timetypes = 'Endtime' | 'Dynamic';

	let selected_poll: polltypes = 'Ranking';
	let selected_time: timetypes = 'Endtime';
	//Something about this feels very scuffed
	const polls: polltypes[] = ['Ranking', 'For/Against', 'Quadratic', 'Cardinal', 'Scheduled'];
	const times: timetypes[] = ['Endtime', 'Dynamic'];

	const pollDescriptions: Record<polltypes, string> = {
		Ranking: `Ranking poll is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`,
		'For/Against': `For Against is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`,
		Quadratic: `For Against is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`,
		Cardinal: `For Against is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`,
		Scheduled: `Sch poll is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`
	};

	const timeDescriptions: Record<timetypes, string> = {
		Endtime: `Time is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`,
		Dynamic: `Dynamic is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`
	};

	const disabled: (polltypes | timetypes)[] = [
		'For/Against',
		'Cardinal',
		'Quadratic',
		'Scheduled',
		'Dynamic'
	];

	const pollIcons: Record<polltypes, any[]> = {
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

	const groupId = $page.url.searchParams.get('id');

	let title = '',
		description = '';
	let tags: TagType[] = [];
	let selectedTag: TagType;
	let status: StatusMessageInfo;
	let end_date = new Date();
	let loading = false;

	const maxDatePickerYear = new Date((new Date().getFullYear() + 5).toString());

	const createPoll = async () => {
		if (selectedTag === undefined) {
			status = { message: 'Must select tag', success: false };
			return;
		}

		loading = true;

		const { res, json } = await fetchRequest('POST', `group/${groupId}/poll/create`, {
			title,
			description,
			start_date: new Date(),
			end_date: new Date(end_date),
			poll_type: 1,
			tag: selectedTag.id,
			dynamic: false
		});

		loading = false;
		if (res.ok) {
			status = { message: 'Success', success: true };
			window.location.href = `groups/${groupId}/polls/${json}`;
		} else status = { message: json.detail[0], success: false };
	};

	const getGroupTags = async () => {
		loading = true;
		const { json } = await fetchRequest('GET', `group/${groupId}/tags?limit=100`);
		loading = false;
		tags = json.results;
	};

	onMount(() => {
		getGroupTags();
	});
</script>

<Layout centering={true}>
	<div class="flex flex-col md:flex-row mt-8 gap-6 ml-8 mr-8 lg:w-[900px]">
		<form
			on:submit|preventDefault={() =>
				!disabled.includes(selected_poll) && !disabled.includes(selected_time)
					? createPoll()
					: null}
			class="md:w-2/3"
		>
			<Loader {loading}>
				<div class="bg-white p-6 shadow-xl flex flex-col gap-6 rounded">
					<h1 class="text-2xl">{$_('Create a poll')}</h1>
					<TextInput required={true} label="Title" bind:value={title} />
					<TextArea required={true} label="Description" bind:value={description} />
					<h2>{$_('End Date')}</h2>
					<DateInput bind:value={end_date} min={new Date()} max={maxDatePickerYear} />
					<h2>{$_('Select Tag')}</h2>
					<div class="flex gap-4 flex-wrap">
						{#each tags as tag}
							<Tag
								onclick={() => (selectedTag = tag)}
								tag={tag.tag_name}
								Class={`cursor-pointer ${selectedTag === tag ? 'bg-blue-600' : 'bg-blue-200'}`}
							/>
						{/each}
					</div>
					{#if disabled.includes(selected_poll) || disabled.includes(selected_time)}
						{$_('This polltype is not implemented yet')}
					{/if}
					<StatusMessage bind:status />
					<ButtonPrimary
						type="submit"
						disabled={disabled.includes(selected_poll) || disabled.includes(selected_time)}
						Class={disabled.includes(selected_poll) || disabled.includes(selected_time)
							? 'bg-gray-400'
							: 'bg-blue-600'}>{$_('Create Poll')}</ButtonPrimary
					>
				</div>
			</Loader>
		</form>
		<div class="md:w-1/3">
			<div class="bg-white p-6 shadow-xl rounded">
				<div class="flex flex-col gap-6">
					{#each polls as poll}
						<ButtonPrimary
							action={() => (selected_poll = poll)}
							buttonStyle={selected_poll === poll ? 'primary' : 'secondary'}
							Class="transition transition-colors"
						>
							<div class="flex items-center text-center">
								{#each pollIcons[poll] as icon}
									<Fa {icon} />
								{/each}

								<span class="ml-10">{$_(poll)}</span>
							</div>
						</ButtonPrimary>
					{/each}
				</div>
				<div class="flex flex-col gap-6 mt-12">
					{#each times as time}
						<ButtonPrimary
							Class={`transition transition-colors ${
								selected_time === time ? 'bg-purple-600' : 'bg-purple-300'
							}`}
							action={() => (selected_time = time)}
						>
							<div class="flex items-center text-center">
								{#each timeIcons[time] as icon}
									<Fa {icon} />
								{/each}
								<span class="ml-10">{$_(time)}</span>
							</div>
						</ButtonPrimary>
					{/each}
				</div>
			</div>
			<div class="bg-white p-6 shadow-xl mt-4 rounded">
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
			</div>
		</div>
	</div>
</Layout>
