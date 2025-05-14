<!-- Event.svelte -->
<script lang="ts">
    import { onMount, onDestroy } from 'svelte';
    import { _ } from 'svelte-i18n';
    import type { scheduledEvent } from '$lib/Schedule/interface';
    import { setDateToMidnight } from '$lib/Generic/Dates';
    import { elipsis } from '$lib/Generic/GenericFunctions';
    import { fetchRequest } from '$lib/FetchRequest';
    import { page } from '$app/stores';

    export let Class = '',
        x: number,
        y: number,
        advancedTimeSettingsDates: Date[] = [],
        selectedDatePosition = '0-0',
        showCreateScheduleEvent = false,
        showEvent = false,
        showEditScheduleEvent = false,
        selectedDate = new Date(),
        month: number,
        year: number,
        events: scheduledEvent[] = [],
        selectedEvent: scheduledEvent,
        workGroups: any[] = [],
        loading = false,
        type: 'user' | 'group',
        scheduleEventCreate: (event: scheduledEvent) => Promise<void>,
        scheduleEventEdit: (event: scheduledEvent) => Promise<void>,
        scheduleEventDelete: (eventId: number) => Promise<void>;

    const currentDate = new Date();
    const groupId = $page.params.groupId || '1';

    const getDate = (year: number, month: number, x: number, y: number) => {
        return new Date(year, month, getDay(x, y));
    };

    const firstDayInMonthWeekday = () => {
        return new Date(year, month, 0).getDay();
    };

    const getDay = (x: number, y: number) => {
        return -firstDayInMonthWeekday() + x + 7 * (y - 1);
    };

    const isToday = () => {
        return (
            getDay(x, y) === currentDate.getDate() &&
            month === currentDate.getMonth() &&
            year === currentDate.getFullYear()
        );
    };

    const getEventsAtDate = (date: Date) => {
        return events
            ?.filter((event) => {
                let startDate = new Date(event.start_date);
                startDate.setHours(0);
                startDate.setMinutes(0);
                startDate.setSeconds(0);
                return startDate <= date && new Date(event.end_date) >= date;
            })
            .sort((a, b) => {
                const dateA = new Date(a.start_date).getTime();
                const dateB = new Date(b.start_date).getTime();
                return dateA === dateB ? a.event_id - b.event_id : dateA - dateB;
            });
    };

    // Frequency options
    let frequencyOptions = [
        { id: 1, name: 'Daily' },
        { id: 2, name: 'Weekly' },
        { id: 3, name: 'Monthly' },
        { id: 4, name: 'Yearly' }
    ];

    // Reminder options (in seconds)
    let reminderOptions = [
        { id: 300, name: '5 minutes before' },
        { id: 600, name: '10 minutes before' },
        { id: 1800, name: '30 minutes before' },
        { id: 3600, name: '1 hour before' },
        { id: 86400, name: '1 day before' }
    ];

    // Members list and selections
    let members: { id: number; name: string }[] = [];
    let selectedMembers: number[] = [];
    let selectedReminders: number[] = [];
    let selectedFrequency: number = 1; // Default to Daily

    let choicesOpenMembers = false;
    let choicesOpenReminders = false;

    const getGroupUsers = async () => {
        let api = `group/${groupId}/users?limit=100`;
        const { json, res } = await fetchRequest('GET', api);
        if (!res.ok) return [];
        return json.results;
    };

    const fetchMembers = async () => {
        if (type === 'group') {
            const users = await getGroupUsers();
            members = users.map((user: any) => ({
                id: user.id,
                name: user.user?.username || `User ${user.id}`
            }));
        }
    };

    const handleOutsideClick = (e: MouseEvent) => {
        const modal = document.querySelector('.modal-content');
        const membersRegion = document.querySelector('.members-clickable-region');
        const remindersRegion = document.querySelector('.reminders-clickable-region');

        if (modal && !modal.contains(e.target as Node)) {
            choicesOpenMembers = false;
            choicesOpenReminders = false;
            return;
        }

        if (choicesOpenMembers && membersRegion && !membersRegion.contains(e.target as Node)) {
            choicesOpenMembers = false;
        }
        if (choicesOpenReminders && remindersRegion && !remindersRegion.contains(e.target as Node)) {
            choicesOpenReminders = false;
        }
    };

    const preventBackgroundScroll = () => {
        document.body.style.overflow = 'hidden';
    };

    const restoreBackgroundScroll = () => {
        document.body.style.overflow = '';
    };

    onMount(async () => {
        const today = new Date();
        let tomorrow = new Date();
        tomorrow.setDate(today.getDate());
        advancedTimeSettingsDates = [today, tomorrow];
        if (type === 'group') {
            await fetchMembers();
        }
        window.addEventListener('click', handleOutsideClick);
    });

    onDestroy(() => {
        window.removeEventListener('click', handleOutsideClick);
        restoreBackgroundScroll();
    });

    $: if (showEvent || showCreateScheduleEvent || showEditScheduleEvent) {
        preventBackgroundScroll();
    } else {
        restoreBackgroundScroll();
    }

    // Initialize values when opening modals
    function initializeModalValues() {
        if (showCreateScheduleEvent) {
            selectedFrequency = 1;
            selectedMembers = [];
            selectedReminders = [];
        } else if (showEditScheduleEvent || showEvent) {
            selectedFrequency = selectedEvent.repeat_frequency && frequencyOptions.some(opt => opt.id === selectedEvent.repeat_frequency)
                ? selectedEvent.repeat_frequency
                : 1;
            selectedMembers = selectedEvent.assignees?.map((member: any) => {
				return member.id
			}) || [];
            selectedReminders = selectedEvent.reminders || [];
        }
    }

    $: if (showCreateScheduleEvent || showEditScheduleEvent || showEvent) {
        initializeModalValues();
    }

    const handleSubmit = async () => {
        const updatedEvent = {
            ...selectedEvent,
            assignee_ids: type === 'group' ? selectedMembers : undefined,
            reminders: type === 'group' ? selectedReminders : undefined,
            repeat_frequency: type === 'group' ? selectedFrequency : undefined
        };

        try {
            if (showCreateScheduleEvent) {
                await scheduleEventCreate(updatedEvent);
                showCreateScheduleEvent = false;
            } else if (showEditScheduleEvent) {
                await scheduleEventEdit(updatedEvent);
                showEditScheduleEvent = false;
            }
        } catch (error) {
            console.error('Error submitting event:', error);
        }
    };

    const toggleSelection = (id: number, type: 'members' | 'reminders', event: Event) => {
        event.stopPropagation();
        if (type === 'members') {
            if (selectedMembers.includes(id)) {
                selectedMembers = selectedMembers.filter((s) => s !== id);
            } else {
                selectedMembers = [...selectedMembers, id];
            }
        } else if (type === 'reminders') {
            if (selectedReminders.includes(id)) {
                selectedReminders = selectedReminders.filter((s) => s !== id);
            } else {
                selectedReminders = [...selectedReminders, id];
            }
        }
    };
</script>

<!-- Calendar Day Display -->
<button
    on:dblclick={() => {
        const clickedDate = new Date(year, month, getDay(x + 1, y));
        clickedDate.setHours(0, 0, 0, 0);
        const dateStr = formatDateForLocalInput(clickedDate);
        selectedEvent = {
            start_date: dateStr,
            end_date: dateStr,
            title: '',
            description: '',
            meeting_link: '',
            event_id: 0,
            schedule_origin_name: type,
            created_by: 0,
            work_group: undefined,
            assignee_ids: [],
            reminders: [],
            repeat_frequency: 1
        };
        selectedDate = clickedDate;
        showCreateScheduleEvent = true;
    }}
    class={`${Class} dark:text-darkmodeText dark:hover:brightness-125 dark:bg-darkobject relative calendar-day border-l border-t border-gray-400 select-none cursor-pointer text-gray-600 transition-all duration-20`}
    id={`${x}-${y}`}
    on:click={() => {
        document.getElementById(selectedDatePosition)?.classList.remove('selected');
        document.getElementById(`${x}-${y}`)?.classList.add('selected');
        selectedDatePosition = `${x}-${y}`;
        selectedDate = new Date(year, month, getDay(x, y));
    }}
>
    <div class="w-full flex flex-col items-center">
        {#key events || month || year || window.innerHeight}
            <div
                class={`px-1 rounded-full flex justify-center
                ${isToday() ? 'bg-secondary text-white w-[25%]' : ''}`}
            >
                <div>{new Date(year, month, getDay(x, y)).getDate()}</div>
            </div>
            {#if getEventsAtDate(getDate(year, month, x, y))?.length > 0}
                {#each getEventsAtDate(getDate(year, month, x, y)) as event, i}
                    {#if (1000 * i) / window.innerHeight < 3}
                        <button
                            on:click={() => {
                                const formattedStart = new Date(event.start_date).toISOString().slice(0, 16);
                                const formattedEnd = new Date(event.end_date).toISOString().slice(0, 16);
                                selectedEvent = {
                                    ...event,
                                    start_date: formattedStart,
                                    end_date: formattedEnd,
                                    description: event.description || '',
                                    meeting_link: event.meeting_link || '',
                                    assignee_ids: event.assignee_ids || [],
                                    reminders: event.reminders || [],
                                    repeat_frequency: event.repeat_frequency || 1
                                };
                                showEvent = true;
                            }}
                            class="break-all bg-secondary w-full text-white text-sm mb-1 text-center"
                        >
                            {elipsis(event.title, 15)}
                        </button>
                    {/if}
                {/each}
            {/if}
        {/key}
    </div>
</button>

<!-- Modal 1: Create Event Modal -->
{#if showCreateScheduleEvent}
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" aria-modal="true" role="dialog">
        <div class="bg-white dark:bg-darkobject p-6 rounded-lg w-full max-w-md overflow-y-auto max-h-[90vh] modal-content">
            <h2 class="text-xl mb-4">{$_('Create Event')}</h2>
            <form on:submit|preventDefault={handleSubmit}>
                <div class="mb-4">
                    <label class="block mb-1">{$_('Title')}</label>
                    <input
                        type="text"
                        bind:value={selectedEvent.title}
                        class="w-full p-2 border rounded"
                        required
                    />
                </div>
                <div class="mb-4">
                    <label class="block mb-1">{$_('Description')}</label>
                    <textarea
                        bind:value={selectedEvent.description}
                        class="w-full p-2 border rounded"
                    ></textarea>
                </div>
                <div class="mb-4">
                    <label class="block mb-1">{$_('Start Date')}</label>
                    <input
                        type="datetime-local"
                        bind:value={selectedEvent.start_date}
                        class="w-full p-2 border rounded"
                        required
                    />
                </div>
                <div class="mb-4">
                    <label class="block mb-1">{$_('End Date')}</label>
                    <input
                        type="datetime-local"
                        bind:value={selectedEvent.end_date}
                        class="w-full p-2 border rounded"
                        required
                    />
                </div>
                <div class="mb-4">
                    <label class="block mb-1">{$_('Meeting Link')}</label>
                    <input
                        type="url"
                        bind:value={selectedEvent.meeting_link}
                        class="w-full p-2 border rounded"
                    />
                </div>
                {#if type === 'group'}
                    <div class="mb-4">
                        <label class="block mb-1">{$_('Work Group')}</label>
                        <select
                            bind:value={selectedEvent.work_group}
                            class="w-full p-2 border rounded"
                        >
                            <option value={undefined}>None</option>
                            {#each workGroups as group}
                                <option value={group}>{group.name}</option>
                            {/each}
                        </select>
                    </div>
                    <div class="mb-4">
                        <label class="block mb-1">{$_('Frequency')}</label>
                        <select
                            bind:value={selectedFrequency}
                            class="w-full p-2 border rounded"
                        >
                            {#each frequencyOptions as option}
                                <option value={option.id}>{option.name}</option>
                            {/each}
                        </select>
                    </div>
                    <div class="mb-4 members-clickable-region relative">
                        <label class="block mb-1">{$_('Assign Members')}</label>
                        <button
                            type="button"
                            class="w-full p-2 border rounded flex justify-between items-center"
                            on:click|stopPropagation={() => (choicesOpenMembers = !choicesOpenMembers)}
                        >
                            <span>{selectedMembers.length > 0 ? `${selectedMembers.length} selected` : 'Select members'}</span>
                            <span>{choicesOpenMembers ? '▲' : '▼'}</span>
                        </button>
                        {#if choicesOpenMembers}
                            <div class="absolute mt-2 bg-white dark:bg-darkobject shadow-xl text-sm w-full z-[90] border border-gray-300 rounded max-h-48 overflow-y-auto" on:click|stopPropagation>
                                <div class="text-xs p-2 border-b border-gray-200">{$_('Select Members')}</div>
                                {#each members as member}
                                    <button
                                        type="button"
                                        on:click|stopPropagation={(e) => toggleSelection(member.id, 'members', e)}
                                        class="w-full hover:bg-gray-300 active:bg-gray-400 dark:bg-slate-700 dark:hover:bg-slate-800 dark:active:bg-slate-900 p-2 px-5 flex justify-between items-center hover:cursor-pointer transition-all"
                                        class:bg-secondary={selectedMembers.includes(member.id)}
                                        class:text-white={selectedMembers.includes(member.id)}
                                    >
                                        {member.name}
                                        <input
                                            type="checkbox"
                                            checked={selectedMembers.includes(member.id)}
                                            on:change|stopPropagation={(e) => toggleSelection(member.id, 'members', e)}
                                            class="ml-2"
                                        />
                                    </button>
                                {/each}
                            </div>
                        {/if}
                    </div>
					{#if !choicesOpenMembers}
						<div class="mb-4 reminders-clickable-region relative">
							<label class="block mb-1">{$_('Reminders')}</label>
							<button
								type="button"
								class="w-full p-2 border rounded flex justify-between items-center"
								on:click|stopPropagation={() => (choicesOpenReminders = !choicesOpenReminders)}
							>
								<span>{selectedReminders.length > 0 ? `${selectedReminders.length} selected` : 'Select reminders'}</span>
								<span>{choicesOpenReminders ? '▲' : '▼'}</span>
							</button>
							{#if choicesOpenReminders}
								<div class="absolute mt-2 bg-white dark:bg-darkobject shadow-xl text-sm w-full z-[90] border border-gray-300 rounded max-h-48 overflow-y-auto" on:click|stopPropagation>
									<div class="text-xs p-2 border-b border-gray-200">{$_('Select Reminders')}</div>
									{#each reminderOptions as reminder}
										<button
											type="button"
											on:click|stopPropagation={(e) => toggleSelection(reminder.id, 'reminders', e)}
											class="w-full hover:bg-gray-300 active:bg-gray-400 dark:bg-slate-700 dark:hover:bg-slate-800 dark:active:bg-slate-900 p-2 px-5 flex justify-between items-center hover:cursor-pointer transition-all"
											class:bg-secondary={selectedReminders.includes(reminder.id)}
											class:text-white={selectedReminders.includes(reminder.id)}
										>
											{reminder.name}
											<input
												type="checkbox"
												checked={selectedReminders.includes(reminder.id)}
												on:change|stopPropagation={(e) => toggleSelection(reminder.id, 'reminders', e)}
												class="ml-2"
											/>
										</button>
									{/each}
								</div>
							{/if}
						</div>
					{/if}
                {/if}
                <div class="flex justify-end gap-2">
                    <button
                        type="button"
                        on:click={() => (showCreateScheduleEvent = false)}
                        class="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400"
                    >
                        {$_('Cancel')}
                    </button>
                    <button
                        type="submit"
                        class="px-4 py-2 bg-secondary text-white rounded hover:bg-secondary-dark"
                        disabled={loading}
                    >
                        {loading ? $_('Loading...') : $_('Create')}
                    </button>
                </div>
            </form>
        </div>
    </div>
{/if}

<!-- Modal 2: Edit Event Modal -->
{#if showEditScheduleEvent}
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" aria-modal="true" role="dialog">
        <div class="bg-white dark:bg-darkobject p-6 rounded-lg w-full max-w-md overflow-y-auto max-h-[90vh] modal-content">
            <h2 class="text-xl mb-4">{$_('Edit Event')}</h2>
            <form on:submit|preventDefault={handleSubmit}>
                <div class="mb-4">
                    <label class="block mb-1">{$_('Title')}</label>
                    <input
                        type="text"
                        bind:value={selectedEvent.title}
                        class="w-full p-2 border rounded"
                        required
                    />
                </div>
                <div class="mb-4">
                    <label class="block mb-1">{$_('Description')}</label>
                    <textarea
                        bind:value={selectedEvent.description}
                        class="w-full p-2 border rounded"
                    ></textarea>
                </div>
                <div class="mb-4">
                    <label class="block mb-1">{$_('Start Date')}</label>
                    <input
                        type="datetime-local"
                        bind:value={selectedEvent.start_date}
                        class="w-full p-2 border rounded"
                        required
                    />
                </div>
                <div class="mb-4">
                    <label class="block mb-1">{$_('End Date')}</label>
                    <input
                        type="datetime-local"
                        bind:value={selectedEvent.end_date}
                        class="w-full p-2 border rounded"
                        required
                    />
                </div>
                <div class="mb-4">
                    <label class="block mb-1">{$_('Meeting Link')}</label>
                    <input
                        type="url"
                        bind:value={selectedEvent.meeting_link}
                        class="w-full p-2 border rounded"
                    />
                </div>
                {#if type === 'group'}
                    <div class="mb-4">
                        <label class="block mb-1">{$_('Work Group')}</label>
                        <select
                            bind:value={selectedEvent.work_group}
                            class="w-full p-2 border rounded"
							disabled
                        >
                            <option value={undefined}>None</option>
                            {#each workGroups as group}
                                <option value={group}>{group.name}</option>
                            {/each}
                        </select>
                    </div>
                    <div class="mb-4">
                        <label class="block mb-1">{$_('Frequency')}</label>
                        <select
                            bind:value={selectedFrequency}
                            class="w-full p-2 border rounded"
                        >
                            {#each frequencyOptions as option}
                                <option value={option.id}>{option.name}</option>
                            {/each}
                        </select>
                    </div>
                    <div class="mb-4 members-clickable-region relative">
                        <label class="block mb-1">{$_('Assign Members')}</label>
                        <button
                            type="button"
                            class="w-full p-2 border rounded flex justify-between items-center"
                            on:click|stopPropagation={() => (choicesOpenMembers = !choicesOpenMembers)}
                        >
                            <span>{selectedMembers.length > 0 ? `${selectedMembers.length} selected` : 'Select members'}</span>
                            <span>{choicesOpenMembers ? '▲' : '▼'}</span>
                        </button>
                        {#if choicesOpenMembers}
                            <div class="absolute mt-2 bg-white dark:bg-darkobject shadow-xl text-sm w-full z-[90] border border-gray-300 rounded max-h-48 overflow-y-auto" on:click|stopPropagation>
                                <div class="text-xs p-2 border-b border-gray-200">{$_('Select Members')}</div>
                                {#each members as member}
                                    <button
                                        type="button"
                                        on:click|stopPropagation={(e) => toggleSelection(member.id, 'members', e)}
                                        class="w-full hover:bg-gray-300 active:bg-gray-400 dark:bg-slate-700 dark:hover:bg-slate-800 dark:active:bg-slate-900 p-2 px-5 flex justify-between items-center hover:cursor-pointer transition-all"
                                        class:bg-secondary={selectedMembers.includes(member.id)}
                                        class:text-white={selectedMembers.includes(member.id)}
                                    >
                                        {member.name}
                                        <input
                                            type="checkbox"
                                            checked={selectedMembers.includes(member.id)}
                                            on:change|stopPropagation={(e) => toggleSelection(member.id, 'members', e)}
                                            class="ml-2"
                                        />
                                    </button>
                                {/each}
                            </div>
                        {/if}
                    </div>
					{#if !choicesOpenMembers}
						<div class="mb-4 reminders-clickable-region relative reminder-div">
							<label class="block mb-1">{$_('Reminders')}</label>
							<button
								type="button"
								class="w-full p-2 border rounded flex justify-between items-center"
								on:click|stopPropagation={() => (choicesOpenReminders = !choicesOpenReminders)}
							>
								<span>{selectedReminders.length > 0 ? `${selectedReminders.length} selected` : 'Select reminders'}</span>
								<span>{choicesOpenReminders ? '▲' : '▼'}</span>
							</button>
							{#if choicesOpenReminders}
								<div class="absolute mt-2 bg-white dark:bg-darkobject shadow-xl text-sm w-full z-[90] border border-gray-300 rounded max-h-48 overflow-y-auto" on:click|stopPropagation>
									<div class="text-xs p-2 border-b border-gray-200">{$_('Select Reminders')}</div>
									{#each reminderOptions as reminder}
										<button
											type="button"
											on:click|stopPropagation={(e) => toggleSelection(reminder.id, 'reminders', e)}
											class="w-full hover:bg-gray-300 active:bg-gray-400 dark:bg-slate-700 dark:hover:bg-slate-800 dark:active:bg-slate-900 p-2 px-5 flex justify-between items-center hover:cursor-pointer transition-all"
											class:bg-secondary={selectedReminders.includes(reminder.id)}
											class:text-white={selectedReminders.includes(reminder.id)}
										>
											{reminder.name}
											<input
												type="checkbox"
												checked={selectedReminders.includes(reminder.id)}
												on:change|stopPropagation={(e) => toggleSelection(reminder.id, 'reminders', e)}
												class="ml-2"
											/>
										</button>
									{/each}
								</div>
							{/if}
						</div>
					{/if}
                {/if}
                <div class="flex justify-end gap-2">
                    <button
                        type="button"
                        on:click={() => (showEditScheduleEvent = false)}
                        class="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400"
                    >
                        {$_('Cancel')}
                    </button>
                    <button
                        type="submit"
                        class="px-4 py-2 bg-secondary text-white rounded hover:bg-secondary-dark"
                        disabled={loading}
                    >
                        {loading ? $_('Loading...') : $_('Update')}
                    </button>
                </div>
            </form>
        </div>
    </div>
{/if}

<!-- Modal 3: View Event Modal -->
{#if showEvent}
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" aria-modal="true" role="dialog">
        <div class="bg-white dark:bg-darkobject p-6 rounded-lg w-full max-w-md overflow-y-auto max-h-[90vh]">
            <h2 class="text-xl mb-4">{selectedEvent.title}</h2>
            <p><strong>{$_('Description')}:</strong> {selectedEvent.description || 'N/A'}</p>
            <p><strong>{$_('Start')}:</strong> {selectedEvent.start_date}</p>
            <p><strong>{$_('End')}:</strong> {selectedEvent.end_date}</p>
            {#if selectedEvent.meeting_link}
                <p>
                    <strong>{$_('Meeting Link')}:</strong>
                    <a href={selectedEvent.meeting_link} target="_blank">{selectedEvent.meeting_link}</a>
                </p>
            {/if}
            {#if type === 'group'}
                {#if selectedEvent.repeat_frequency !== undefined}
                    <p>
                        <strong>{$_('Frequency')}:</strong>
                        {frequencyOptions.find(opt => opt.id === selectedEvent.repeat_frequency)?.name || 'N/A'}
                    </p>
                {/if}
                {#if selectedEvent.assignee_ids?.length}
                    <p>
                        <strong>{$_('Assigned Members')}:</strong>
                        {selectedEvent.assignee_ids.map(id => members.find(m => m.id === id)?.name || `User ${id}`).join(', ')}
                    </p>
                {/if}
                {#if selectedEvent.reminders?.length}
                    <p>
                        <strong>{$_('Reminders')}:</strong>
                        {selectedEvent.reminders.map(time => reminderOptions.find(r => r.id === time)?.name || `${time} seconds`).join(', ')}
                    </p>
                {/if}
            {/if}
            <div class="flex justify-end gap-2 mt-4">
                <button
                    on:click={() => (showEvent = false)}
                    class="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400"
                >
                    {$_('Close')}
                </button>
                <button
                    on:click={() => {
                        showEvent = false;
                        showEditScheduleEvent = true;
                    }}
                    class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
                >
                    {$_('Edit')}
                </button>
                <button
                    on:click={() => scheduleEventDelete(selectedEvent.event_id)}
                    class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
                >
                    {$_('Delete')}
                </button>
            </div>
        </div>
    </div>
{/if}

<!-- Helper function to format date for local datetime-local input -->
<script context="module" lang="ts">
    function formatDateForLocalInput(date: Date): string {
        const pad = (num: number) => num.toString().padStart(2, '0');
        const year = date.getFullYear();
        const month = pad(date.getMonth() + 1);
        const day = pad(date.getDate());
        const hours = pad(date.getHours() || 0);
        const minutes = pad(date.getMinutes() || 1);
        return `${year}-${month}-${day}T${hours}:${minutes}`;
    }
</script>

<style>
    .selected {
        box-shadow: inset 0 0 10px 1px rgba(0, 0, 0, 0.4) !important;
    }

    .today {
        box-shadow: inset 0 0 4px 1px var(--secondary) !important;
        background-color: var(--secondary);
    }

    .today.selected {
        box-shadow: inset 0 0 10px 1px var(--secondary) !important;
    }

    .calendar-day {
        display: flex;
        justify-content: center;
        min-height: 80px;
    }

    .calendar-day:hover {
        box-shadow: inset 0 0 2px 2px rgba(0, 0, 0, 0.1);
    }

    .members-clickable-region,
    .reminders-clickable-region {
        position: relative;
        z-index: 0;
    }

    .modal-content {
        position: relative;
        z-index: 50;
    }

    .members-clickable-region .absolute,
    .reminders-clickable-region .absolute {
        top: 100%;
        left: 0;
        right: 0;
    }
</style>