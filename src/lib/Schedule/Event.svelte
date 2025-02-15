<script lang="ts">
	import { _ } from 'svelte-i18n';
	import Modal from '$lib/Generic/Modal.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';

	export let showEvent = false,
		showCreateScheduleEvent = false,
		showEditScheduleEvent = false,
		title = '',
		description = '',
		start_date: Date|null,
		end_date: Date|null,
		meeting_link = '',
		workGroup: any,
		workGroups: any[] = [],
		type = '',
		loading = false;

	export const scheduleEventCreate = () => {},
		scheduleEventEdit = () => {},
		scheduleEventDelete = () => {};
</script>

<!-- Allows user to see event -->
<Modal bind:open={showEvent}>
	<div slot="header">{title}</div>
	<div slot="body">
		<div class="flex flex-col">
			<span>{$_('From')}: {formatDate(start_date?.toString())}</span>
			<span>{$_('To')}: {formatDate(end_date?.toString())}</span>
			<span>{$_('Description')}: {description || $_('No description')} </span>
			{#if workGroup}
				{$_('Work Group')}:<span>{workGroup?.name}</span>
			{/if}
			<span>{$_('Meeting link')}: {meeting_link || $_('No meeting link')}</span>
		</div>
	</div>
	<div slot="footer">
		<Button
			action={() => {
				showEditScheduleEvent = true;
				showEvent = false;
			}}>{$_('Edit Event')}</Button
		>
	</div>
</Modal>

<!-- Modal for creating one's own/group scheduled event -->
<Modal Class="md:w-[700px]" bind:open={showCreateScheduleEvent}>
	<div slot="header">{$_('Create Event')}</div>
	<div slot="body">
		<Loader bind:loading>
			<form on:submit|preventDefault={scheduleEventCreate}>
				<TextInput placeholder="Event name" label="Title" bind:value={title} required />
				<TextArea label="Description" bind:value={description} />
				{#if type === 'group'}
					<div class="text-left">
						{$_('Work Group')}
						<Select
							bind:value={workGroup}
							labels={workGroups.map((group) => group.name)}
							values={workGroups.map((group) => group.id)}
						/>
					</div>
				{/if}
				<!-- <input bind:value={start_date} type="datetime-local" />
				<input bind:value={end_date} type="datetime-local" /> -->
				<div class="md:flex md:gap-4">
					<div class="text-left">
						{$_('From')}
						<!-- <DateInput bind:value={start_date} /> -->
						<input type="datetime-local" bind:value={start_date} />
					</div>

					{$_('To')}
					<!-- <DateInput bind:value={end_date} /> -->
					<input type="datetime-local" bind:value={end_date} />
				</div>
				<TextInput placeholder="Meeting link" label="Meeting link" bind:value={meeting_link} />
				<Button Class="mt-4" type="submit" action={scheduleEventCreate}>{$_('Submit')}</Button>
			</form>
		</Loader>
	</div>
</Modal>

<!-- Opens a window which allows users to edit a schedule (TODO: refactor so there's just one combined modal for edit and create) -->
<Modal bind:open={showEditScheduleEvent}>
	<div slot="header">{$_('Edit Event')}</div>
	<div slot="body">
		<Loader bind:loading>
			<form on:submit|preventDefault={scheduleEventEdit}>
				<!-- <DateInput bind:value={start_date} format="yyyy-MM-dd HH:mm" />
				<DateInput bind:value={end_date} format="yyyy-MM-dd HH:mm" /> -->
				<!-- min={start_date ? addDateOffset(start_date, 1, 'hour') : new Date()} -->
				<TextInput label="Event title" bind:value={title} />
				<TextArea label="Event description" bind:value={description} />
				<div class="md:flex md:gap-4">
					<div class="text-left">
						{$_('From')}
						<input type="datetime-local" bind:value={start_date} />
					</div>
					{$_('To')}
					<input type="datetime-local" bind:value={end_date} />
				</div>
				<TextInput label="Meeting link" bind:value={meeting_link} />
			</form>
		</Loader>
	</div>
	<div slot="footer">
		<Button type="submit" action={scheduleEventEdit}>{$_('Submit')}</Button>
		<Button buttonStyle="warning" action={scheduleEventDelete}>{$_('Delete')}</Button>
	</div>
</Modal>
