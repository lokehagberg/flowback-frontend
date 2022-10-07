<script lang="ts">
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';

	type polltypes = 'Ranking' | 'For Against' | 'Quadratic' | 'Cardinal';
	type timetypes = 'Time' | 'Dynamic' | 'Scheduled';

	let selected_poll: polltypes = 'Ranking';
	let selected_time: timetypes = 'Time';
	//Something about this feels very scuffed
	const polls: polltypes[] = ['Ranking', 'For Against', 'Quadratic', 'Cardinal'];
	const times: timetypes[] = ['Time', 'Dynamic', 'Scheduled'];

	const pollDescriptions: Record<polltypes, string> = {
		Ranking: `Ranking poll is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`,
		'For Against': `For Against is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`,
		Quadratic: `For Against is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`,
		Cardinal: `For Against is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`
	};

	const timeDescriptions: Record<timetypes, string> = {
		Time: `Time is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`,
		Dynamic: `Dynamic is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`,
		Scheduled: `Sch poll is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam
					incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi
					itaque omnis eaque tempora quod maiores, dolores velit dolorem?`
	};

	const disabled: (polltypes | timetypes)[] = ['For Against', 'Cardinal', 'Quadratic', 'Scheduled', 'Dynamic'];
	const groupId = $page.url.searchParams.get("id")

	let description = ""
	let title = ""

	const createPoll = () => {
		console.log('poll created!');
		fetchRequest('POST', `group/${groupId}/poll/create`, {
			title,
			description,
			start_date: new Date(),
			end_date: new Date(new Date().setMonth(12)),
			poll_type: 1,
			tag: 1,
			dynamic:false
		})
	};


</script>

<Layout>
	<form
		on:submit|preventDefault={() =>
			!disabled.includes(selected_poll) && !disabled.includes(selected_time) ? createPoll() : null}
		class="flex items-start justify-center gap-8 mt-24 ml-8 mr-8"
	>
		<div class="bg-white p-6 shadow-xl flex flex-col gap-6 w-2/3">
			<h1 class="text-2xl">Create a poll</h1>
			<TextInput label="Title" bind:value={title}/>
			<TextInput label="Description" bind:value={description}/>
			{#if disabled.includes(selected_poll) || disabled.includes(selected_time)}
				This polltype is not implemented yet
			{/if}
			<ButtonPrimary
				type="submit"
				Class={disabled.includes(selected_poll) || disabled.includes(selected_time)
					? 'bg-gray-400'
					: 'bg-blue-600'}>Create Poll</ButtonPrimary
			>
		</div>
		<div class="w-1/3">
			<div class="bg-white p-6 shadow-xl">
				<div class="flex flex-col gap-6">
					{#each polls as poll}
						<ButtonPrimary
							action={() => (selected_poll = poll)}
							buttonStyle={selected_poll === poll ? 'primary' : 'secondary'}>{poll}</ButtonPrimary
						>
					{/each}
				</div>
				<div class="flex flex-col gap-6 mt-12">
					{#each times as time}
						<ButtonPrimary
							Class={selected_time === time ? 'bg-purple-600' : 'bg-purple-300'}
							action={() => (selected_time = time)}>{time}</ButtonPrimary
						>
					{/each}
				</div>
			</div>
			<div class="bg-white p-6 shadow-xl mt-4">
				<div>
					{#each Object.entries(pollDescriptions) as [pollType, description]}
						{#if selected_poll === pollType}
							{description}
						{/if}
					{/each}
				</div>
				<div class="mt-6">
					{#each Object.entries(timeDescriptions) as [timeType, description]}
						{#if selected_time === timeType}
							{description}
						{/if}
					{/each}
				</div>
			</div>
		</div>
	</form>
</Layout>
