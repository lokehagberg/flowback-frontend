<script lang="ts">
	let sections = [
		{
			title: 'Arbetsmarknad',
			voters: []
		},
		{
			title: 'Skolpolitik',
			voters: [
				{ name: 'Alma Petersson', percentage: 95 },
				{ name: 'Linus Johansson', percentage: 88 },
				{ name: 'Mark Persson', percentage: 82 }
			]
		},
		{
			title: 'Ekonomisk politik',
			voters: []
		},
		{
			title: 'Finansiering',
			voters: []
		},
		{
			title: 'Intern administration',
			voters: []
		},
		{
			title: 'Kampanj',
			voters: []
		}
	];

	let expandedSection: any = null;

	const toggleSection = (index: any) => {
		expandedSection = expandedSection === index ? null : index;
	};
</script>

<div>
	{#each sections as section, index}
		<div class="section">
			<button class=" flex justify-between w-full section-title" on:click={() => toggleSection(index)}>
				<span>{section.title}</span>
				<span>{expandedSection === index ? '▲' : '▼'}</span>
			</button>
			{#if expandedSection === index}
				{#if section.voters.length > 0}
					<div class="voter-list">
						{#each section.voters as voter}
							<div class="voter-item">
								<span>{voter.name}</span>
								<span>
									{voter.percentage}%
									<input type="radio" name={section.title} />
								</span>
							</div>
						{/each}
					</div>
				{:else}
					<div class="voter-list">Inga rekommenderade väljare.</div>
				{/if}
			{/if}
		</div>
	{/each}
</div>

<style>
	.section {
		margin-bottom: 1rem;
		border-bottom: 1px solid #ccc;
	}
	.section-title {
		cursor: pointer;
		font-size: 1.2rem;
		padding: 0.5rem;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}
	.voter-list {
		padding-left: 1rem;
	}
	.voter-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0.5rem;
	}
	.voter-item input[type='radio'] {
		margin-left: 0.5rem;
	}
</style>
