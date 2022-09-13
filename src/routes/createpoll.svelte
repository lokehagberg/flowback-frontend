<script lang="ts">
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';

	type polltypes = 'Ranking' | 'For Against' | 'Quadratic' | 'Cardinal';
	type timetypes = 'Time' | 'Dynamic' | 'Scheduled';

	let polltype: polltypes = 'Ranking';
	let timetype: timetypes = 'Time';
	const pollTypes: polltypes[] = ['Ranking', 'For Against', 'Quadratic', 'Cardinal'];
	const timeTypes: timetypes[] = ['Time', 'Dynamic', 'Scheduled'];

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

	const createPoll = () => {
		console.log('poll created!');
	};
</script>

<Layout>
	<form
		on:submit|preventDefault={createPoll}
		class="flex items-start justify-center gap-8 mt-24 ml-8 mr-8"
	>
		<div class="bg-white p-6 shadow-xl flex flex-col gap-6 w-2/3">
			<h1 class="text-2xl">Create a poll</h1>
			<TextInput label="Title" />
			<TextInput label="Description" />
			<ButtonPrimary>Create Poll</ButtonPrimary>
		</div>
		<div class="w-1/3">
			<div class="bg-white p-6 shadow-xl">
				<div class="flex flex-col gap-6">
					{#each pollTypes as poll}
						<ButtonPrimary
							action={() => (polltype = poll)}
							buttonStyle={polltype === poll ? 'primary' : 'secondary'}>{poll}</ButtonPrimary
						>
					{/each}
				</div>
				<div class="flex flex-col gap-6 mt-12">
					{#each timeTypes as timetype_type}
						<ButtonPrimary
							className={timetype === timetype_type ? 'bg-purple-600' : 'bg-purple-300'}
							action={() => (timetype = timetype_type)}>{timetype_type}</ButtonPrimary
						>
					{/each}
				</div>
			</div>
			<div class="bg-white p-6 shadow-xl mt-4">
				<div>
					{#each Object.entries(pollDescriptions) as [pollType, description]}
						{#if polltype === pollType}
							{description}
						{/if}
					{/each}
				</div>
				<div class="mt-6">
					{#each Object.entries(timeDescriptions) as [timeType, description]}
						{#if timetype === timeType}
							{description}
						{/if}
					{/each}
				</div>
			</div>
		</div>
	</form>
</Layout>
