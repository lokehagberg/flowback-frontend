<script lang="ts">
	import Layout from '$lib/Generic/Layout.svelte';
	import Fa from 'svelte-fa';
	import {
		faUser,
		faBell,
		faPieChart,
		faArrowLeft,
		faInfo,
		faWarning
	} from '@fortawesome/free-solid-svg-icons';
	import { _ } from 'svelte-i18n';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import { configToReadable } from '$lib/utils/configToReadable';
	import type { report } from '$lib/Generic/interfaces';
	import { linkToPost } from '$lib/Generic/GenericFunctions';
	import Modal from '$lib/Generic/Modal.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { goto } from '$app/navigation';

	type PageType =
		| 'profile'
		| 'notifications'
		| 'poll-process'
		| 'info'
		| 'reports';

	interface SettingsPage {
		page: PageType;
		icon: any;
		text: string;
	}

	const sidebarItems: SettingsPage[] = [
		{
			page: 'profile',
			icon: faUser,
			text: 'User Profile'
		},
		{
			page: 'notifications',
			icon: faBell,
			text: 'Notifications'
		},
		{
			page: 'poll-process',
			icon: faPieChart,
			text: 'Poll Process'
		},
		{
			page: 'info',
			icon: faInfo,
			text: 'Information'
		},
		{
			page: 'reports',
			icon: faWarning,
			text: 'Reports'
		}
	];

	let selectedPage: PageType = 'profile',
		optionsDesign =
			'flex items-center gap-3 w-full cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700 p-2 transition-all',
		userConfig = {
			notificationSettings: {
				schedule: {
					invited_to_event: false,
					event_date_changed: false,
					event_canceled: false,
					new_member_added: false,
					event_frequency_changed: false
				},
				kanban: {
					task_assigned: false,
					task_priority_changed: false,
					task_status_changed: false
				},
				posts: {
					new_thread_created: false,
					new_poll_created: false,
					vote_on_comment: false
				}
			},
			pollSettings: {
				area_voting: false,
				proposal_creation: false,
				prediction_statement_creation: false,
				prediction_betting: false,
				delegate_voting: false,
				voting: false
			}
		},
		reports: report[] = [],
		serverConfig: any = {},
		version = '70',
		open = false,
		selectedRepport: report = {
			description: '',
			group_id: 0,
			post_id: 0,
			post_type: 'poll',
			post_title: '',
			post_description: '',
			title: '',
			admin_action: 'nothing'
		};

	const userUpdate = async () => {
		const { res, json } = await fetchRequest('POST', 'user/update', {
			user_config: JSON.stringify(userConfig)
		});
	};

	const getServerConfig = async () => {
		const { res, json } = await fetchRequest('GET', 'server/config');

		if (!res.ok) return;

		serverConfig = json;
	};

	const getUserConfig = async () => {
		const { res, json } = await fetchRequest('GET', 'user');

		if (res.ok && json.user_config) userConfig = JSON.parse(json.user_config);
	};

	const saveUserConfig = async () => {
		const { res, json } = await fetchRequest('POST', 'user/update', {
			user_config: JSON.stringify(userConfig)
		});
	};

	const getReportList = async () => {
		const { res, json } = await fetchRequest('GET', 'server/reports');

		if (!res.ok) return;

		reports = json?.results;
	};

	const a = (key1: string, key2: string = '') => {
		if (key2 === '') {
			//@ts-ignore
			return userConfig.pollSettings[key1];
		}
		//@ts-ignore
		else return userConfig.notificationSettings[key1][key2];
	};

	onMount(() => {
		getUserConfig();
		getServerConfig();
		getReportList();
	});
</script>

<Layout centered>
	<div class="flex mt-6 gap-6">
		<div
			class="bg-white dark:bg-darkobject dark:text-darkmodeText w-[300px] p-6 rounded border shadow"
		>
			<div class="flex items-center mb-4 gap-4">
				<button
					class="text-gray-600 hover:text-primary dark:text-secondary transition-colors"
					on:click={() => goto('/home')}
				>
					<Fa icon={faArrowLeft} />
				</button>
				<h1
					class="text-xl text-left text-primary dark:text-secondary font-semibold"
				>
					{$_('Settings')}
				</h1>
			</div>

			<div class="mt-4">
				{#each sidebarItems as item}
					<button
						on:click={() => (selectedPage = item.page)}
						class={optionsDesign}
						class:bg-gray-100={selectedPage === item.page}
						class:dark:bg-gray-800={selectedPage === item.page}
						class:border-l-2={selectedPage === item.page}
						class:border-primary={selectedPage === item.page}
					>
						<Fa icon={item.icon} class="w-5 h-5" />{$_(item.text)}
					</button>
				{/each}
			</div>
		</div>
		<div
			class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 w-[400px] rounded border shadow"
		>
			<ul class="flex flex-col">
				{#if selectedPage === 'profile'}
					<li
						class="text-lg text-primary dark:text-secondary font-semibold mb-3"
					>
						{$_('General')}
					</li>
					<RadioButtons2
						Class="pb-4"
						ClassInner="flex items-center justify-between px-3 py-2 rounded cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700"
						name="radio1"
						label="Who can see my profile"
						labels={['All', 'Only people in my groups', 'Only group admins']}
						values={['1', '2', '3']}
						radioSide="right"
					/>
					<RadioButtons2
						ClassInner="flex items-center justify-between px-3 py-2 rounded cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700"
						name="radio2"
						label="Who can contact me in chat"
						labels={['All', 'Only people in my groups', 'Only group admins']}
						values={['1', '2', '3']}
						radioSide="right"
					/>

					<div class="pt-4">
						<div class="cursor-pointer hover:underline">
							{$_('Give me all my data')}
						</div>
						<div class="text-red-600 cursor-pointer hover:underline mt-2">
							{$_('Delete account')}
						</div>
					</div>
				{:else if selectedPage === 'notifications' && userConfig?.notificationSettings}
					{#each Object.entries(userConfig.notificationSettings) as [key1, settings]}
						<li>
							<span
								class="text-lg text-primary dark:text-secondary font-semibold"
								>{configToReadable(key1)}</span
							>
							<ul class="pl-4 pt-2">
								<span class="my-4">{$_('Notify me when')}...</span>
								{#each Object.entries(settings) as [key2, setting]}
									<li
										class="flex justify-between p-2 rounded hover:bg-gray-100"
									>
										<span>{$_(configToReadable(key2))}</span>
										<input
											on:change={saveUserConfig}
											value={userConfig.pollSettings}
											type="checkbox"
											on:input={(e) => {
												//@ts-ignore
												userConfig.notificationSettings[key1][key2] =
													//@ts-ignore
													e.target.checked;

												userUpdate();
											}}
											checked={a(key1, key2)}
										/>
									</li>
								{/each}
							</ul>
						</li>
					{/each}
				{:else if selectedPage === 'poll-process' && userConfig?.pollSettings}
					<span class="text-xl text-primary dark:text-secondary font-semibold"
						>{$_('Poll Phases')}</span
					>
					<span>{$_('Select the phases you want to participate in')}.</span>
					<ul class="gap-2 pl-4">
						{#each Object.entries(userConfig.pollSettings) as [key, setting]}
							<li class="flex justify-between p-2 rounded hover:bg-gray-100">
								<span>{$_(configToReadable(key))}</span>
								<input
									type="checkbox"
									on:change={saveUserConfig}
									value={userConfig.pollSettings}
									on:input={(e) => {
										//@ts-ignore
										userConfig.pollSettings[key] =
											//@ts-ignore
											e.target.checked;

										userUpdate();
									}}
									checked={a(key)}
								/>
							</li>
						{/each}
					</ul>
				{:else if selectedPage === 'info'}
					<div>{$_('Frontend version')}: {version}</div>
					<div>{$_('Backend version')}: {serverConfig.VERSION}</div>
				{:else if selectedPage === 'reports'}
					<span
						class="text-lg text-primary dark:text-secondary font-semibold mb-1"
						>{$_('Reports')}</span
					>
					{#if reports?.length > 0}
						<div class="flex flex-col gap-2 mt-2">
							{#each reports as report}
								<button
									on:click={() => {
										selectedRepport = report;
										open = true;
									}}
									class="flex items-start gap-3 p-3 rounded-lg border border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700 text-left transition-colors w-full"
								>
									<Fa
										icon={faWarning}
										class="text-yellow-500 mt-0.5 flex-shrink-0"
									/>
									<div class="min-w-0">
										<div
											class="font-medium text-gray-800 dark:text-darkmodeText truncate"
										>
											{report?.title}
										</div>
										<div
											class="text-sm text-gray-500 dark:text-gray-400 line-clamp-1"
										>
											{report?.description}
										</div>
									</div>
								</button>
							{/each}
						</div>
					{:else}
						<p class="text-sm text-gray-500 dark:text-gray-400 mt-2">
							{$_('There are currently no reports')}
						</p>
					{/if}
				{/if}
			</ul>
		</div>
	</div>
</Layout>

<Modal bind:open Class="max-w-[520px]">
	<div slot="header" class="flex items-center gap-2">
		<Fa icon={faWarning} class="text-yellow-500" />
		<span>{$_('Report Details')}</span>
	</div>
	<div slot="body" class="flex flex-col gap-4 text-left">
		<!-- Report info -->
		<div
			class="bg-yellow-50 dark:bg-yellow-900/20 rounded-lg p-3 border border-yellow-200 dark:border-yellow-800"
		>
			<div
				class="text-xs font-semibold uppercase tracking-wide text-yellow-700 dark:text-yellow-400 mb-2"
			>
				{$_('Report')}
			</div>
			<div class="font-semibold text-gray-800 dark:text-darkmodeText">
				{selectedRepport?.title || $_('No title')}
			</div>
			{#if selectedRepport?.description}
				<div class="text-sm text-gray-600 dark:text-gray-400 mt-1">
					{selectedRepport.description}
				</div>
			{/if}
		</div>

		<!-- Post type badge -->
		<div class="flex items-center gap-2">
			<span
				class="px-2 py-0.5 text-xs rounded-full font-medium"
				class:bg-blue-100={selectedRepport.post_type === 'poll'}
				class:text-blue-700={selectedRepport.post_type === 'poll'}
				class:bg-purple-100={selectedRepport.post_type === 'thread'}
				class:text-purple-700={selectedRepport.post_type === 'thread'}
			>
				{selectedRepport.post_type === 'poll' ? $_('Poll') : $_('Thread')}
			</span>
		</div>

		<div
			class="bg-gray-50 dark:bg-gray-800 rounded-lg p-3 border border-gray-200 dark:border-gray-700"
		>
			<div
				class="text-xs font-semibold uppercase tracking-wide text-gray-500 dark:text-gray-400 mb-2"
			>
				{$_('Admin Action')}
			</div>
			{selectedRepport.admin_action}
		</div>
		<!-- Reported post details -->
		{#await fetchRequest('GET', selectedRepport.post_type === 'poll' ? `home/polls?group_ids=${selectedRepport.group_id}&id=${selectedRepport.post_id}` : `group/thread/list?group_ids=${selectedRepport.group_id}&id=${selectedRepport.post_id}`) then { res, json }}
			{#if res.ok}
				{@const post = json?.results[0]}
				{#if post}
					<div
						class="bg-gray-50 dark:bg-gray-800 rounded-lg p-3 border border-gray-200 dark:border-gray-700"
					>
						<div
							class="text-xs font-semibold uppercase tracking-wide text-gray-500 dark:text-gray-400 mb-2"
						>
							{$_('Reported Post')}
						</div>
						<div class="font-medium text-gray-800 dark:text-darkmodeText">
							{post?.title}
						</div>
						{#if post?.description}
							<div
								class="text-sm text-gray-500 dark:text-gray-400 mt-1 line-clamp-3"
							>
								{post.description}
							</div>
						{/if}
					</div>
				{/if}
			{/if}
		{/await}

		<!-- View Post button -->
		<Button
			Class="w-full"
			onClick={() =>
				goto(
					`${linkToPost(
						selectedRepport.post_id,
						selectedRepport.group_id,
						selectedRepport.post_type
					)}`
				)}
		>
			{$_('View Post')}
		</Button>
	</div>
</Modal>
