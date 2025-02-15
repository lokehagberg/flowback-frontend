<script lang="ts">
	import Layout from '$lib/Generic/Layout.svelte';
	import Fa from 'svelte-fa';
	import {
		faUser,
		faBell,
		faPieChart,
		faArrowLeft,
		faInfo
	} from '@fortawesome/free-solid-svg-icons';
	import { _ } from 'svelte-i18n';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import { configToReadable } from '$lib/utils/configToReadable';

	let selectedPage: 'profile' | 'notifications' | 'poll-process' | 'info' = 'notifications',
		optionsDesign =
			'flex items-center gap-2 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700 p-1 transition-all',
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
		version = '0.1.2';

	const userUpdate = async () => {
		const { res, json } = await fetchRequest('POST', 'user/update', {
			user_config: JSON.stringify(userConfig)
		});
	};

	const getUserConfig = async () => {
		const { res, json } = await fetchRequest('GET', 'user');
		if (res.ok) {
			userConfig = JSON.parse(json.user_config);
		}
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
	});
</script>

<Layout centered>
	<div class="flex mt-6 gap-6">
		<div class="bg-white dark:bg-darkobject dark:text-darkmodeText w-[300px] p-6">
			<button
				class="flex items-center gap-2 text-gray-600 hover:text-primary dark:text-secondary transition-colors mb-4"
				on:click={() => history.back()}
			>
				<Fa icon={faArrowLeft} />
				{$_('Back')}
			</button>
			<h1 class="text-xl text-left text-primary dark:text-secondary font-bold">{$_('Settings')}</h1>
			<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
			<!-- svelte-ignore a11y-click-events-have-key-events -->
			<div class="mt-4">
				<button
					on:click={() => (selectedPage = 'profile')}
					class={`${optionsDesign}`}
					class:border-l-2={selectedPage === 'profile'}
					class:border-primary={selectedPage === 'profile'}
				>
					<Fa icon={faUser} />{$_('Profile')}
				</button>
				<button
					on:click={() => (selectedPage = 'notifications')}
					class={`${optionsDesign}`}
					class:border-l-2={selectedPage === 'notifications'}
					class:border-primary={selectedPage === 'notifications'}
				>
					<Fa icon={faBell} />{$_('Notification')}
				</button>
				<button
					on:click={() => (selectedPage = 'poll-process')}
					class={`${optionsDesign}`}
					class:border-l-2={selectedPage === 'poll-process'}
					class:border-primary={selectedPage === 'poll-process'}
				>
					<Fa icon={faPieChart} />{$_('Poll Process')}
				</button>
				<button
					on:click={() => (selectedPage = 'info')}
					class={`${optionsDesign}`}
					class:border-l-2={selectedPage === 'info'}
					class:border-primary={selectedPage === 'info'}
				>
					<Fa icon={faInfo} />{$_('Info')}
				</button>
			</div>
		</div>
		<div class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 w-[400px]">
			<ul class="flex flex-col">
				{#if selectedPage === 'profile'}
					<li>{$_('Profile')}</li>
					<RadioButtons2
						name="radio1"
						label="Who can see my profile"
						labels={['All', 'Only people in my groups', 'Only group admins']}
						values={['1', '2', '3']}
					/>
					<RadioButtons2
						name="radio2"
						label="Who can contact me in chat"
						labels={['All', 'Only people in my groups', 'Only group admins']}
						values={['1', '2', '3']}
					/>
					<div>{$_('Give me all data')}</div>
					<div>{$_('Delete account')}</div>
				{:else if selectedPage === 'notifications' && userConfig?.notificationSettings}
					{$_('Notify me when')}...
					{#each Object.entries(userConfig.notificationSettings) as [key1, settings]}
						<li>
							<span class="text-xl text-primary dark:text-secondary font-bold"
								>{configToReadable(key1)}</span
							>
							<ul>
								{#each Object.entries(settings) as [key2, setting]}
									<li class="flex justify-between">
										<span>{$_(configToReadable(key2))}</span>
										<input
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
					<span class="text-xl text-primary dark:text-secondary font-bold">{$_('Poll Phases')}</span
					>
					<span>{$_('Select the phases you want to participate in')}.</span>
					{#each Object.entries(userConfig.pollSettings) as [key, setting]}
						<li class="flex justify-between">
							<span>{$_(configToReadable(key))}</span>
							<input
								type="checkbox"
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
				{:else if selectedPage === 'info'}
					Version: {version}
				{/if}
			</ul>
		</div>
	</div>
</Layout>
