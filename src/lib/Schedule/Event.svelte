<script lang="ts">
	import { _ } from 'svelte-i18n';
	import Modal from '$lib/Generic/Modal.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import type { scheduledEvent, WorkGroupScheduledEventCreate } from './interface';
	import { onMount, tick, afterUpdate } from 'svelte';

	export let showEvent = false,
		showCreateScheduleEvent = false,
		showEditScheduleEvent = false,
		selectedEvent: scheduledEvent,
		workGroups: any[] = [],
		type = '',
		loading = false;

	export let scheduleEventCreate = () => {},
		scheduleEventEdit = () => {},
		scheduleEventDelete = () => {};

	// Initialize temporary event objects
	let createEvent: scheduledEvent = {
		start_date: '',
		end_date: '',
		title: '',
		description: '',
		meeting_link: '',
		event_id: 0,
		schedule_origin_name: type,
		created_by: 0,
		work_group: undefined
	};
	let editEvent: scheduledEvent = {
		start_date: '',
		end_date: '',
		title: '',
		description: '',
		meeting_link: '',
		event_id: 0,
		schedule_origin_name: type,
		created_by: 0,
		work_group: undefined
	};
	let deleteEventId: number = 0;

	// Format and validate date for datetime-local input
	function formatDateForLocalInput(date: Date): string {
		const pad = (num: number) => num.toString().padStart(2, '0');
		const year = date.getFullYear();
		const month = pad(date.getMonth() + 1);
		const day = pad(date.getDate());
		const hours = pad(date.getHours() || 0);
		const minutes = pad(date.getMinutes() || 1);
		return `${year}-${month}-${day}T${hours}:${minutes}`;
	}

	// Initialize when modals open
	function initializeCreateEvent() {
		const startDate = selectedEvent.start_date ? new Date(selectedEvent.start_date) : new Date();
		const endDate = selectedEvent.end_date ? new Date(selectedEvent.end_date) : new Date();
		createEvent = {
			start_date: formatDateForLocalInput(startDate),
			end_date: formatDateForLocalInput(endDate),
			title: '',
			description: '',
			meeting_link: '',
			event_id: 0,
			schedule_origin_name: type,
			created_by: 0,
			work_group: undefined
		};
	}

	function initializeEditEvent() {
		const startDate = selectedEvent.start_date ? new Date(selectedEvent.start_date) : new Date();
		const endDate = selectedEvent.end_date ? new Date(selectedEvent.end_date) : new Date();
		editEvent = {
			start_date: formatDateForLocalInput(startDate),
			end_date: formatDateForLocalInput(endDate),
			title: selectedEvent.title || '',
			description: selectedEvent.description || '',
			meeting_link: selectedEvent.meeting_link || '',
			event_id: selectedEvent.event_id,
			schedule_origin_name: selectedEvent.schedule_origin_name || type,
			created_by: selectedEvent.created_by || 0,
			work_group: selectedEvent.work_group || undefined
		};
	}

	// Reset when modals close
	function resetEvents() {
		createEvent = {
			start_date: '',
			end_date: '',
			title: '',
			description: '',
			meeting_link: '',
			event_id: 0,
			schedule_origin_name: type,
			created_by: 0,
			work_group: undefined
		};
		editEvent = {
			start_date: '',
			end_date: '',
			title: '',
			description: '',
			meeting_link: '',
			event_id: 0,
			schedule_origin_name: type,
			created_by: 0,
			work_group: undefined
		};
		deleteEventId = 0;
	}

	// Handle modal open/close
	$: if (showCreateScheduleEvent) {
		tick().then(() => initializeCreateEvent());
	} else {
		resetEvents();
	}

	$: if (showEditScheduleEvent) {
		tick().then(() => initializeEditEvent());
	} else {
		resetEvents();
	}

	$: if (showEvent) {
		deleteEventId = selectedEvent.event_id;
	} else {
		resetEvents();
	}
</script>

<!-- Allows user to see event -->
<Modal bind:open={showEvent} Class="min-w-[400px] max-w-[500px] z-50">
	<div slot="body">
		<div class="text-center">
			<h2 class="pb-1 font-semibold break-words text-xl w-full">{selectedEvent.title}</h2>
			{#if type === 'group'}
				<p class="w-full">{selectedEvent.work_group?.name || $_('No workgroup assigned')}</p>
			{/if}
		</div>
		<div class="flex flex-col gap-1 mt-4 w-full">
			<div class="flex justify-between w-full">
				<p class="font-bold">{$_('From')}</p>
				<p>
					{selectedEvent.start_date
						? new Intl.DateTimeFormat('sv-SE', {
								weekday: 'short',
								day: '2-digit',
								month: 'long',
								hour: '2-digit',
								minute: '2-digit'
							})
								.format(new Date(selectedEvent.start_date))
								.replace(/\b\w/g, (char) => char.toUpperCase())
						: $_('No start date set')}
				</p>
			</div>
			<div class="flex justify-between w-full">
				<p class="font-bold">{$_('To')}</p>
				<p>
					{selectedEvent.end_date
						? new Intl.DateTimeFormat('sv-SE', {
								weekday: 'short',
								day: '2-digit',
								month: 'long',
								hour: '2-digit',
								minute: '2-digit'
							})
								.format(new Date(selectedEvent.end_date))
								.replace(/\b\w/g, (char) => char.toUpperCase())
						: $_('No end date set')}
				</p>
			</div>
		</div>
		{#if selectedEvent?.meeting_link && selectedEvent.meeting_link !== ''}
			<div class="text-left mt-1 w-full">
				<p class="font-bold">{$_('Meeting link')}</p>
				<p class="w-full">{selectedEvent.meeting_link}</p>
			</div>
		{/if}
		{#if selectedEvent.description && selectedEvent.description !== ''}
			<div class="text-left mt-1 w-full">
				<p class="font-bold">{$_('Description')}</p>
				<p class="max-h-[25vh] overflow-scroll break-words w-full whitespace-pre-wrap">
					{selectedEvent.description}
				</p>
			</div>
		{/if}
		<div class="text-left mt-1 w-full">
			<p class="font-bold">{$_('Attachments')}</p>
		</div>
	</div>
	<div slot="footer" class="flex justify-between gap-4 mx-6 mb-3">
		<Button
			Class="w-full py-1"
			buttonStyle="primary-light"
			onClick={() => {
				showEditScheduleEvent = true;
				showEvent = false;
			}}>{$_('Edit')}</Button
		>
		<Button
			Class="w-full py-1"
			buttonStyle="warning-light"
			onClick={() => {
				if (typeof scheduleEventDelete === 'function') {
					scheduleEventDelete(deleteEventId);
				} else {
					console.error('Event.svelte - scheduleEventDelete is not a function');
				}
			}}>{$_('Delete')}</Button
		>
	</div>
</Modal>

<!-- Modal for creating one's own/group scheduled event -->
<Modal Class="min-w-[400px] md:w-[700px]" bind:open={showCreateScheduleEvent}>
	<div slot="body">
		<Loader bind:loading>
			<form>
				<h1 class="text-lg pb-3 text-left text-primary dark:text-secondary font-semibold">
					{$_('Create Event')}
				</h1>
				<div class="pb-2">
					<TextInput Class="text-md" label="Title" bind:value={createEvent.title} required />
				</div>
				<TextArea
					Class="text-md"
					inputClass="whitespace-pre-wrap"
					label="Description"
					bind:value={createEvent.description}
				/>
				{#if type === 'group'}
					<div class="text-left">
						<label class="block text-md py-3" for="work-group">
							{$_('Work Group')}
							<Select
								Class="width:100%"
								bind:value={createEvent.work_group}
								labels={workGroups.map((group) => group.name)}
								values={workGroups.map((group) => group.id)}
								innerLabel={$_('No workgroup assigned')}
								innerLabelOn={true}
							/>
						</label>
					</div>
				{/if}
				<div class="w-full md:flex md:gap-4">
					<div class="text-left flex-1">
						<label class="block text-md pt-2" for="create-start-date">
							{$_('From')}
						</label>
						<input
							id="create-start-date"
							type="datetime-local"
							bind:value={createEvent.start_date}
							class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject"
						/>
					</div>
					<div class="text-left flex-1">
						<label class="block text-md pt-2" for="create-end-date">
							{$_('To')}
						</label>
						<input
							id="create-end-date"
							type="datetime-local"
							bind:value={createEvent.end_date}
							class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject"
						/>
					</div>
				</div>
				<div class="pt-2">
					<TextInput label="Meeting link" bind:value={createEvent.meeting_link} />
				</div>
			</form>
		</Loader>
	</div>
	<div slot="footer" class="flex justify-between gap-4 mx-6 mb-3">
		<Button
			Class="w-full py-1"
			buttonStyle="primary-light"
			type="submit"
			onClick={() => {
				if (typeof scheduleEventCreate === 'function') {
					scheduleEventCreate(createEvent);
				} else {
					console.error('Event.svelte - scheduleEventCreate is not a function');
				}
			}}>{$_('Create')}</Button
		>
		<Button
			Class="w-full py-1"
			buttonStyle="warning-light"
			onClick={() => {
				showCreateScheduleEvent = false;
			}}>{$_('Cancel')}</Button
		>
	</div>
</Modal>

<!-- Opens a window which allows users to edit a schedule -->
<Modal bind:open={showEditScheduleEvent} Class="min-w-[400px] md:w-[700px] z-50">
	<div slot="body">
		<Loader bind:loading>
			<form on:submit|preventDefault={() => scheduleEventEdit(editEvent)}>
				<div class="pb-2">
					<TextInput label="Title" bind:value={editEvent.title} required />
				</div>
				<TextArea
					label="Description"
					bind:value={editEvent.description}
					rows={3}
					Class="overflow-scroll"
					inputClass="whitespace-pre-wrap"
				/>
				{#if type === 'group'}
					<div class="text-left">
						<label class="block text-md">
							{$_('Work Group')}
						</label>
						<Select
							Class="width:100%"
							classInner="border-gray-300 rounded border"
							labels={workGroups.map((group) => group.name)}
							values={workGroups.map((group) => group.id)}
							bind:value={editEvent.work_group}
							innerLabel={$_('No workgroup assigned')}
							innerLabelOn={true}
						/>
					</div>
				{/if}
				<div class="md:flex md:gap-4">
					<div class="text-left flex-1">
						<label class="block text-md pt-2" for="edit-start-date">
							{$_('From')}
						</label>
						<input
							id="edit-start-date"
							type="datetime-local"
							bind:value={editEvent.start_date}
							class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject"
						/>
					</div>
					<div class="text-left flex-1">
						<label class="block text-md pt-2" for="edit-end-date">
							{$_('To')}
						</label>
						<input
							id="edit-end-date"
							type="datetime-local"
							bind:value={editEvent.end_date}
							class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject"
						/>
					</div>
				</div>
				<div class="pt-2">
					<TextInput label="Meeting link" bind:value={editEvent.meeting_link} />
				</div>
			</form>
		</Loader>
	</div>
	<div slot="footer" class="flex justify-between gap-4 mx-6 mb-3">
		<Button
			Class="w-full py-1"
			buttonStyle="primary-light"
			type="submit"
			onClick={() => {
				if (typeof scheduleEventEdit === 'function') {
					scheduleEventEdit(editEvent);
				} else {
					console.error('Event.svelte - scheduleEventEdit is not a function');
				}
			}}>{$_('Confirm')}</Button
		>
		<Button
			Class="w-full py-1"
			buttonStyle="warning-light"
			onClick={() => {
				showEditScheduleEvent = false;
			}}>{$_('Cancel')}</Button
		>
	</div>
</Modal>