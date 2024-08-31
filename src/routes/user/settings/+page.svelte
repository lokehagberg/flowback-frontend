<script lang="ts">
	import Layout from '$lib/Generic/Layout.svelte';
	import Fa from 'svelte-fa';
	import { faUser, faBell, faPieChart } from '@fortawesome/free-solid-svg-icons';

	let selectedPage: 'profile' | 'notifications' | 'poll-process' = 'notifications',
		optionsDesign = 'flex items-center gap-2 cursor-pointer hover:bg-gray-100 p-1 transition-all',
		notificationSettingsTitles = ['Schedule', 'Kanban', 'Posts'],
		notificationSettings = [
			[
				'I am invited to an event',
				"an event's date has been changed",
				'an event has been canceled',
				'a new member has been added',
				"an event's frequency has been changed"
			],
			['a task is assigned to you', "a task's priority is changed", "a task's status is changed"],
			['a new thread is created', 'a new poll is created', 'someone votes on my comment']
		],
		pollSettings = [
			[
				'Area voting',
				'Proposal creation',
				'Prediction statement creation',
				'Prediction betting',
				'Delegate voting',
				'Voting'
			]
		];
</script>

<Layout centered>
	<div class="flex mt-6 gap-6">
		<div class="bg-white w-[300px] p-6">
			<h1 class="text-xl text-left text-primary font-bold">Settings</h1>
			<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
			<!-- svelte-ignore a11y-click-events-have-key-events -->
			<ul class="mt-4">
				<li
					on:click={() => (selectedPage = 'profile')}
					class={`${optionsDesign}`}
					class:border-l-2={selectedPage === 'profile'}
					class:border-primary={selectedPage === 'profile'}
				>
					<Fa icon={faUser} />Profile
				</li>
				<li
					on:click={() => (selectedPage = 'notifications')}
					class={`${optionsDesign}`}
					class:border-l-2={selectedPage === 'notifications'}
					class:border-primary={selectedPage === 'notifications'}
				>
					<Fa icon={faBell} />Notification
				</li>
				<li
					on:click={() => (selectedPage = 'poll-process')}
					class={`${optionsDesign}`}
					class:border-l-2={selectedPage === 'poll-process'}
					class:border-primary={selectedPage === 'poll-process'}
				>
					<Fa icon={faPieChart} />Poll Process
				</li>
			</ul>
		</div>
		<div class="bg-white p-6 w-[400px]">
			<ul class="flex flex-col">
				{#if selectedPage === 'profile'}
					<li>Profile</li>
					<!-- TODO: Create generic list of lists with checkbox component -->
				{:else if selectedPage === 'notifications'}
					Notify me when...
					{#each notificationSettingsTitles as title, i}
						<li>
							<span class="text-xl text-primary font-bold">{title}</span>
							<ul>
								{#each notificationSettings[i] as setting}
									<li class="flex justify-between">
										<span>{setting}</span>
										<input type="checkbox" />
									</li>
								{/each}
							</ul>
						</li>
					{/each}
				{:else if selectedPage === 'poll-process'}
					<span class="text-xl text-primary font-bold">Poll Phases</span>
					<span>Select the phases you want to participate in.</span>
					{#each pollSettings[0] as setting}
						<li class="flex justify-between">
							<span>{setting}</span>
							<input type="checkbox" />
						</li>
					{/each}
				{/if}
			</ul>
		</div>
	</div>
</Layout>
