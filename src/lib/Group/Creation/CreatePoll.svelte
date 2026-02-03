<script lang="ts">
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { _ } from 'svelte-i18n';
	import Loader from '$lib/Generic/Loader.svelte';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import { goto } from '$app/navigation';
	import { createPoll as createPollBlockchain } from '$lib/Blockchain_v1_Ethereum/javascript/pollsBlockchain';
	import FileUploads from '$lib/Generic/File/FileUploads.svelte';
	import AdvancedTimeSettings from './AdvancedTimeSettings.svelte';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';
	import Tab from '$lib/Generic/Tab.svelte';
	import { env } from '$env/dynamic/public';
	import {
		faAlignLeft,
		faArrowLeft,
		faCalendarAlt
	} from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { onDestroy, onMount } from 'svelte';
	import Select from '$lib/Generic/Select.svelte';
	import type { WorkGroup } from '../WorkingGroups/interface';
	import { groupUserStore } from '$lib/Group/interface';
	import type { pollType } from './interface';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';

	let title = $state(''),
		description = $state(''),
		times: Date[] = $state([]),
		isPublic = $state(false),
		loading = $state(false),
		images: File[] = $state([]),
		isFF = $state(false),
		pushToBlockchain = $state(true),
		selectedPoll: pollType = $state('Text Poll'),
		selectedPage: 'poll' | 'thread' = $state(
			$page.url.searchParams.get('type') === 'thread' ? 'thread' : 'poll'
		),
		tags: { id: number }[] = $state([]),
		workGroups: WorkGroup[] = $state([]),
		workGroup: number | null = $state(null),
		permissions: any;

	const groupId = $page.url.searchParams.get('id');

	const goBack = () => {
		const groupId = $page.url.searchParams.get('id');
		goto(`/groups/${groupId}`);
	};

	const getGroupTags = async () => {
		const { res, json } = await fetchRequest('GET', `group/${groupId}/tags`);

		if (res.ok) tags = json?.results;
	};

	const createPoll = async () => {
		loading = true;
		const formData = new FormData();
		let blockchain_id;

		if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE' && pushToBlockchain) {
			blockchain_id = await createPollBlockchain(Number(groupId), title);
			if (blockchain_id)
				formData.append('blockchain_id', blockchain_id.toString());
		}

		formData.append('title', title);
		formData.append('description', description);
		formData.append('start_date', times[0].toISOString());
		if (selectedPoll === 'Text Poll') {
			formData.append('area_vote_end_date', times[1].toISOString());
			formData.append('proposal_end_date', times[2].toISOString());
			formData.append('prediction_statement_end_date', times[3].toISOString());
			formData.append('prediction_bet_end_date', times[4].toISOString());
			formData.append('delegate_vote_end_date', times[5].toISOString());
			formData.append('vote_end_date', times[6].toISOString());
			formData.append('end_date', times[7].toISOString());
		} else if (selectedPoll === 'Date Poll') {
			formData.append('end_date', times[1].toISOString());
		}
		formData.append('allow_fast_forward', isFF.toString());
		formData.append(
			'poll_type',
			(selectedPoll === 'Text Poll' ? 4 : 3).toString()
		);
		formData.append('dynamic', selectedPoll === 'Text Poll' ? 'false' : 'true');
		formData.append('public', isPublic.toString());
		formData.append('pinned', 'false');
		formData.append('tag', tags[0]?.id?.toString() || '1');

		images.forEach((image) => {
			formData.append('attachments', image);
		});

		if (workGroup && selectedPoll === 'Date Poll' && !isPublic)
			formData.append('work_group_id', workGroup.toString());

		const { res, json } = await fetchRequest(
			'POST',
			`group/${groupId}/poll/create`,
			formData,
			true,
			false
		);

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not create Poll',
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({
			message: 'Poll Created',
			success: true
		});

		if (groupId) {
			goto(`groups/${groupId}/polls/${json}?source=group`);
		}
	};

	const createThread = async () => {
		let thread: {
			title: string;
			description?: string;
			public?: boolean;
			work_group_id?: number | null;
		} = {
			title
		};

		if (description) thread.description = description;

		if (workGroup) thread.work_group_id = workGroup;

		if (isPublic) thread.public = isPublic;

		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.url.searchParams.get('id')}/thread/create`,
			thread
		);
		if (!res.ok) {
			// poppup = { message: "Couldn't create Thread", success: false };
			return;
		}

		goto(
			`groups/${$page.url.searchParams.get('id')}/thread/${json}?source=create`
		);
	};

	const getWorkGroupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${groupId}/list`);

		if (!res.ok) return;
		workGroups = json?.results;
		workGroups = workGroups.filter((workGroup) => workGroup.joined);
	};

	const handleKeyDown = (event: KeyboardEvent) => {
		// Check for a specific key, e.g., the "k" key:
		if (event.ctrlKey && event.key === 'Enter') {
			selectedPage === 'poll' ? createPoll() : createThread();
		}
	};
	onDestroy(() => {
		//	TODO: Fix issue where reloading leads to 404 page
		// 	document.removeEventListener('keydown', handleKeyDown);
	});

	onMount(async () => {
		document.addEventListener('keydown', handleKeyDown);
		getGroupTags();
		getWorkGroupList();
	});

	$effect(() => {
		times =
			selectedPoll === 'Text Poll'
				? new Array(8).fill(new Date())
				: new Array(2).fill(new Date());
	});
</script>

<form
	onsubmitcapture={(e) => {
		e.preventDefault();
		selectedPage === 'poll' ? createPoll() : createThread();
	}}
	class="relative md:w-2/3 max-w-[800px] dark:text-darkmodeText my-6"
>
	<button
		class="absolute -left-12 bg-white dark:bg-darkobject p-3 rounded shadow z-40 hover:bg-gray-100 active:bg-gray-200 text-gray-600 hover:text-gray-800 dark:text-gray-400 dark:hover:text-gray-200"
		onclick={goBack}
		type="button"
		aria-label="Go back"
	>
		<Fa icon={faArrowLeft} />
	</button>
	<Loader {loading}>
		<div
			class="bg-white dark:bg-darkobject p-6 shadow-xl flex flex-col gap-3 rounded"
		>
			<Tab
				displayNames={['Poll', 'Thread']}
				tabs={['poll', 'thread']}
				bind:selectedPage
			/>

			{#if selectedPage === 'poll'}
				<RadioButtons2
					name="poll Content"
					label="Poll Content"
					ClassInner="mr-2 flex gap-2 items-center"
					horizontal
					labels={['Text Poll', 'Date Poll']}
					values={['Text Poll', 'Date Poll']}
					icons={[faAlignLeft, faCalendarAlt]}
					bind:value={selectedPoll}
				/>
			{/if}

			<TextInput
				inputClass="bg-white"
				required
				label="Title"
				bind:value={title}
			/>
			<TextArea
				label="Description"
				bind:value={description}
				inputClass="whitespace-pre-wrap"
			/>
			<FileUploads bind:files={images} disableCropping />

			{#if selectedPage === 'poll'}
				<div class="rounded border border-gray-200 dark:border-gray-500 p-2">
					{#key times}
						<AdvancedTimeSettings bind:times />
					{/key}
				</div>
			{/if}

			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<RadioButtons bind:Yes={isPublic} label="Public?" />
			{/if}

			{#if selectedPage === 'poll' && (permissions?.allow_fast_forward || $groupUserStore?.is_admin)}
				<RadioButtons bind:Yes={isFF} label="Fast Forward?" />
			{/if}

			{#if env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE'}
				<RadioButtons bind:Yes={pushToBlockchain} label="Push to Blockchain?" />
			{/if}

			<Select
				disabled={(selectedPage !== 'thread' && selectedPoll !== 'Date Poll') ||
					isPublic}
				classInner="border border-gray-300"
				label={$_('Work Group')}
				labels={[
					'No workgroup selected',
					...workGroups.map((workGroup) => workGroup.name)
				]}
				values={[null, ...workGroups.map((workGroup) => workGroup.id)]}
				bind:value={workGroup}
				disableFirstChoice
			/>

			<Button type="submit" disabled={loading} Class={'bg-primary p-3 mt-3'}
				>{$_('Post')}</Button
			>
		</div>
	</Loader>
</form>
