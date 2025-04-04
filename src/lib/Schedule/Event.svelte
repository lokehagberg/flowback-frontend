<script lang="ts">
	import { _ } from 'svelte-i18n';
	import Modal from '$lib/Generic/Modal.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import type { scheduledEvent } from './interface';

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
		<div class="text-left mt-1 w-full">
			<p class="font-bold">{$_('Meeting link')}</p>
			<p class="w-full">{selectedEvent.meeting_link}</p>
		</div>
		<div class="text-left mt-1 w-full">
			<p class="font-bold">{$_('Description')}</p>
			<p class="max-h-[25vh] overflow-scroll break-words w-full">{selectedEvent.description}</p>
		</div>
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
		<Button Class="w-full py-1" buttonStyle="warning-light" onClick={scheduleEventDelete}
			>{$_('Delete')}</Button
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
					<TextInput Class="text-md" label="Title" bind:value={selectedEvent.title} required />
				</div>
				<TextArea Class="text-md" label="Description" bind:value={selectedEvent.description} />
				{#if type === 'group'}
					<div class="text-left">
						<label class="block text-md">
							{$_('Work Group')}
						</label>
						<Select
							Class="width:100%"
							bind:value={selectedEvent.work_group}
							labels={workGroups.map((group) => group.name)}
							values={workGroups.map((group) => group.id)}
						/>
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
							bind:value={selectedEvent.start_date}
							class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject
						   {selectedEvent.start_date ? 'text-black' : 'text-gray-500'}"
						/>
					</div>

					<div class="text-left flex-1">
						<label class="block text-md pt-2" for="create-end-date">
							{$_('To')}
						</label>
						<input
							id="create-end-date"
							type="datetime-local"
							bind:value={selectedEvent.end_date}
							class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject
							{selectedEvent.end_date ? 'text-black' : 'text-gray-500'}"
						/>
					</div>
				</div>
				<div class="pt-2">
					<TextInput label="Meeting link" bind:value={selectedEvent.meeting_link} />
				</div>
			</form>
		</Loader>
	</div>
	<div slot="footer" class="flex justify-between gap-4 mx-6 mb-3">
		<Button
			Class="w-full py-1"
			buttonStyle="primary-light"
			type="submit"
			onClick={scheduleEventCreate}>{$_('Create')}</Button
		>
		<Button
			Class="w-full py-1"
			buttonStyle="warning-light"
			onClick={() => (showCreateScheduleEvent = false)}>{$_('Cancel')}</Button
		>
	</div>
</Modal>

<!-- Opens a window which allows users to edit a schedule (TODO: refactor so there's just one combined modal for edit and create) -->
<Modal bind:open={showEditScheduleEvent} Class="min-w-[400px] md:w-[700px] z-50">
	<!-- <div slot="header">{$_('Edit Event')}</div> -->
	<div slot="body">
		<Loader bind:loading>
			<form on:submit|preventDefault={scheduleEventEdit}>
				<!-- <DateInput bind:value={start_date} format="yyyy-MM-dd HH:mm" />
				<DateInput bind:value={end_date} format="yyyy-MM-dd HH:mm" /> -->
				<!-- min={start_date ? addDateOffset(start_date, 1, 'hour') : new Date()} -->
				<div class="pb-2">
					<TextInput label="Title" bind:value={selectedEvent.title} required />
				</div>
				<TextArea
					label="Description"
					bind:value={selectedEvent.description}
					rows={3}
					Class="overflow-scroll"
				/>
				{#if type === 'group'}
					<div class="text-left">
						<label class="block text-md">
							{$_('Work Group')}
						</label>
						<Select
							Class="width:100%"
							bind:value={selectedEvent.work_group}
							labels={workGroups.map((group) => group.name)}
							values={workGroups.map((group) => group.id)}
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
							bind:value={selectedEvent.start_date}
							class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject
						   {selectedEvent.start_date ? 'text-black' : 'text-gray-500'}"
						/>
					</div>
					<div class="text-left flex-1">
						<label class="block text-md pt-2" for="edit-end-date">
							{$_('To')}
						</label>
						<input
							id="edit-end-date"
							type="datetime-local"
							bind:value={selectedEvent.end_date}
							class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject
							{selectedEvent.start_date ? 'text-black' : 'text-gray-500'}"
						/>
					</div>
				</div>
				<div class="pt-2">
					<TextInput label="Meeting link" bind:value={selectedEvent.meeting_link} />
				</div>
			</form>
		</Loader>
	</div>
	<div slot="footer" class="flex justify-between gap-4 mx-6 mb-3">
		<Button
			Class="w-full py-1"
			buttonStyle="primary-light"
			type="submit"
			onClick={scheduleEventEdit}>{$_('Confirm')}</Button
		>
		<Button
			Class="w-full py-1"
			buttonStyle="warning-light"
			onClick={() => (showEditScheduleEvent = false)}>{$_('Cancel')}</Button
		>
	</div>
</Modal>
